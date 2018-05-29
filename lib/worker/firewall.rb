require "worker"
require "google"
require "digital_ocean"

# Ensures that droplets are whitelisted on the API firewall on Google.
class FirewallWorker < Worker
    include Google
    include DigitalOcean

    instance(
        ARGV[0] # Firewall name
    )

    def initialize(name)
        @name = name
        @service = auth(Google::Apis::ComputeBeta::ComputeService.new)
    end

    def run
        firewall = @service.get_firewall(project_id, @name) \
                   or raise "Unable to find firewall #{@name}"
        google_ips = firewall.source_ranges.sort
        droplet_ips = digital_ocean.droplets.all.map(&:ip).sort
        unless google_ips == droplet_ips
            request = Google::Apis::ComputeBeta::Firewall.new
            request.source_ranges = droplet_ips
            @service.patch_firewall(project_id, @name, request)
            log("Firewall #{firewall.name} patched with #{droplet_ips}")
        end
    end
end
