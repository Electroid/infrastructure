# Script to sync a service ip to cloudflare dns

domain = "stratus.network"
public_ip = open('http://whatismyip.akamai.com').read
puts "Detected public ip as #{public_ip}"

zone = Zone.cached(domain)
records = zone.refresh
puts "Found #{records.size} records for dns zone"

if extension = ENV["WEB_RECORD"]
	domain = "#{extension}.#{domain}"
end
puts "Searching for record #{domain}"

if record = records.select{|r| r.name == domain}.first
	record.content = public_ip
	record.save
	puts "Saved!"
else
	puts "Unable to find record #{domain}"
	exit 1
end
