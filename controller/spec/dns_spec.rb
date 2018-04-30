require "minecraft/dns/parser"

describe Minecraft::DNS::Parser do

    parser = Minecraft::DNS::Parser.new
    servers = [
        ["Lobby",      "us", nil,       nil, nil],
        ["Lobby-1",    "tm", nil,       1,   25],
        ["Apple",      "us", "private", 2,   25],
        ["Willy123",   "us", "private", 3,   25],
        ["Lobby-2",    "us", nil,       5,   25],
        ["01official", "tm", nil,       10,  25],
        ["Lobby-3",    "us", nil,       15,  25],
        ["Beta",       "us", nil,       20,  25],
        ["02official", "tm", nil,       25,  25],
        ["03official", "tm", nil,       30,  25],
    ].map{|values| RecursiveOpenStruct.new({
        name: values[0],
        bungee_name: values[0].downcase,
        datacenter: values[1].upcase,
        settings_profile: values[2],
        num_online: values[3],
        max_players: values[4]
    })}.sort_by{|s| (s.num_online || 0) / ([1, s.max_players || 0].max).to_f}

    it "validates mock server data" do
        expect(servers.size).to eql 10
        expect(servers[0].name).to eql "Lobby"
        expect(servers[1].name).to eql "Lobby-1"
        expect(servers[9].name).to eql "03official"
    end

    context "ip address" do
        it "parses a single name" do
            expect(parser.parse("beta.mc", servers)).to eql "beta.beta.default.svc.cluster.local"
            expect(parser.parse("willy123.mc", servers)).to eql "willy123.willy123.default.svc.cluster.local"
        end

        it "parses a name with datacenter" do
            expect(parser.parse("beta.us.mc", servers)).to eql "beta.beta.default.svc.cluster.local"
            expect(parser.parse("lobby.tm.mc", servers)).to eql "lobby-0.lobby.tm.svc.cluster.local"
        end

        it "parses a name with a selector" do
            expect(parser.parse("official.1.mc", servers)).to eql "official-1.official.tm.svc.cluster.local"
            expect(parser.parse("lobby.full.mc", servers)).to eql "lobby-2.lobby.default.svc.cluster.local"
        end

        it "parses a name with a selector and datacenter" do
            expect(parser.parse("lobby.2.us.mc", servers)).to eql "lobby-2.lobby.default.svc.cluster.local"
            expect(parser.parse("official.empty.tm.mc", servers)).to eql "official-0.official.tm.svc.cluster.local"
        end
    end

    context "components" do
        it "does not parse without proper suffix" do
            expect(parser.parse_components("alpha")).to be_nil
            expect(parser.parse_components("beta.lan")).to be_nil
            expect(parser.parse_components("beta.mc.cluster")).to be_nil
        end

        it "parses a single name" do
            expect(parser.parse_server_components("beta.mc", servers)).to eql({
                name: "beta", index: nil, datacenter: "US", selector: nil, server: servers[7]
            })
            expect(parser.parse_server_components("willy123.mc", servers)).to eql({
                name: "willy123", index: nil, datacenter: "US", selector: nil, server: servers[3]
            })
        end

        it "parses a name with datacenter" do
            expect(parser.parse_server_components("beta.us.mc", servers)).to eql({
                name: "beta", index: nil, datacenter: "US", selector: nil, server: servers[7]
            })
            expect(parser.parse_server_components("lobby.tm.mc", servers)).to eql({
                name: "lobby", index: 0, datacenter: "TM", selector: nil, server: servers[1]
            })  
        end

        it "parses a name with a selector" do
            expect(parser.parse_server_components("official.1.mc", servers)).to eql({
                name: "official", index: 1, datacenter: "TM", selector: nil, server: servers[8]
            })
            expect(parser.parse_components("lobby.full.mc")).to eql({
                name: "lobby", index: nil, datacenter: nil, selector: "full"
            })
            expect(parser.parse_server_components("lobby.full.mc", servers)).to eql({
                name: "lobby", index: 2, datacenter: "US", selector: "full", server: servers[6]
            })
        end

        it "parses a name with a selector and datacenter" do
            expect(parser.parse_server_components("lobby.2.us.mc", servers)).to eql({
                name: "lobby", index: 2, datacenter: "US", selector: nil, server: servers[6]
            })
            expect(parser.parse_server_components("official.empty.tm.mc", servers)).to eql({
                name: "official", index: 0, datacenter: "TM", selector: "empty", server: servers[5]
            })
        end
    end

    context "datacenter" do
        it "parses valid datacenters" do
            expect(parser.parse_datacenter("us")).to eql "US"
            expect(parser.parse_datacenter("eU")).to eql "EU"
            expect(parser.parse_datacenter("Tm")).to eql "TM"
        end

        it "raises an exception when invalid" do
            expect{parser.parse_datacenter("blah")}.to raise_error(ParseException)
            expect{parser.parse_datacenter("")}.to raise_error(ParseException)
            expect{parser.parse_datacenter(nil)}.to raise_error(ParseException)
        end
    end

    context "selectors" do
        it "parses indexes as integers" do
            expect(parser.parse_selector("1")).to eql 1
            expect(parser.parse_selector("09")).to eql 9
            expect(parser.parse_selector("11")).to eql 11
            expect(parser.parse_selector("-1")).to eql 0
        end

        it "parses the special selector keywords" do
            expect(parser.parse_selector("rand")).to eql "rand"
            expect(parser.parse_selector("Empty")).to eql "empty"
            expect(parser.parse_selector("FULL")).to eql "full"
        end

        it "raises an exception when invalid" do
            expect{parser.parse_selector("blah")}.to raise_error(ParseException)
            expect{parser.parse_selector("")}.to raise_error(ParseException)
            expect{parser.parse_selector(nil)}.to raise_error(ParseException)
        end
    end

end
