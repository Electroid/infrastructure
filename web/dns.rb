# Script to sync web ip to cloudflare dns

public_ip = open('http://whatismyip.akamai.com').read
puts "Detected public ip as #{public_ip}"

zone = Zone.cached("stratus.network")
records = zone.refresh
puts "Found #{records.size} records for dns zone"

unless record = records.select{|r| r.name == "stratus.network"}.first
	record = zone.build_record(content: public_ip, name: "stratus.network", type: "A", ttl: 1, service_mode: 1)
	puts "Creating new record for website"
end

record.content = public_ip
record.save

puts "Saved!"
