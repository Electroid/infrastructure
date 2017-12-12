# Script to sync a service ip to cloudflare dns

domain = "stratus.network"
public_ip = open('http://whatismyip.akamai.com').read
puts "Detected public ip as #{public_ip}"

zone = Zone.cached(domain)
records = zone.refresh
puts "Found #{records.size} records for dns zone"

if extension = ENV["WEB_RECORD"]
	query = "#{extension}.#{domain}"
end
puts "Searching for record #{query}"

if record = records.select{|r| r.name == query}.first
	record.content = public_ip
	record.save
	puts "Saved!"
else
	puts "Unable to find record #{query}"
	exit 1
end
