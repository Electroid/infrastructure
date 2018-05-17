require "set"
require "worker"
require "kubernetes"
require "digital_ocean"

# Ensures that droplet tags are properly converted into node labels.
class LabelWorker < Worker
    include DigitalOcean
    include Kubernetes

    def initialize(parent_label)
        @parent_label = parent_label
    end

    def run
        droplets = digital_ocean.droplets.all
        nodes.each do |node|
            if droplet = (droplets.select{|droplet| droplet.name == node.name}.first rescue nil)
                tags_to_labels(droplet, node)
            end
        end
    end

    def tags_to_labels(droplet, node)
        return unless droplet && node
        expected = tags(droplet)
        actual = labels(node)
        patch = {}
        # Add keys that are defined as tags on the droplet,
        # but are not labels on the node.
        for key in expected
            unless actual.include?(key)
                patch[key] = "true"
                # Delete keys of already synced labels
                # to prevent double-checking.
                actual.delete(key)
            end
        end
        # Check for labels that must be removed,
        # because there is no corresponding tag.
        for key in actual
            unless expected.include?(key)
                patch[key] = nil
            end
        end
        # Only send the patch if there are any changes.
        unless patch.empty?
            log("Node #{node.name} patched with labels #{patch.to_s}")
            node.label(patch)
        end
    end

    def tags(droplet)
        droplet.tags
               .map{|tag| "#{@parent_label}/#{tag}"}
               .to_set
    end

    def labels(node)
        node.labels
            .select{|label| label.starts_with?(@parent_label)}
            .map{|label| label.first}
            .to_set
    end
end
