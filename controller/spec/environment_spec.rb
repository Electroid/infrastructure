require "environment"

describe Env do
    it "gets the environment variable" do
        expect(Env.get("HOME")).to eql ENV["HOME"]
        expect(Env.get("PWD")).to eql ENV["PWD"]
    end

    it "checks if environment variable exists" do
        expect(Env.has?("HOME")).to be true
        expect(Env.has?("FAKE-123-456")).to be false
    end

    it "gets multiple environment variables" do
        expect(Env.get_multi("PATH", File::SEPARATOR)).to eql ENV["PATH"].split(File::SEPARATOR)
        expect(Env.get_multi("HOME")).to eql [ENV["HOME"]]
        expect(Env.get("HOME", 1)).to eql [ENV["HOME"]]
    end

    it "ignores key case sensitivity" do
        expect(Env.get("home")).to_not be_nil
        expect(Env.get("Home")).to_not be_nil
        expect(Env.get("HOME")).to_not be_nil
    end

    it "sets an environment variable as override" do
        expect(Env.set("HOME", "not-force", false)).to be_nil
        expect(Env.get("HOME")).to eql ENV["HOME"]
        expect(Env.set("HOME", "force", true)).to eql "force"
    end

    it "extracts hostname and replica information" do
        expect(Env.replica).to eql -1
        expect(Env.set("HOSTNAME", "server-3", true)).to eql "server-3"
        expect(Env.host).to eql "server-3"
        expect(Env.replica).to eql 3
    end
end
