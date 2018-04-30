require "worker/base"
require "kubernetes/all"
require "stratus"
require "git"

# Ensures that Pods are healthy and properly deployed.
# TODO: Still in progress, yet to change
class PodWorker < Worker
    include Kubernetes

    def initialize(git_user, git_repo, git_path, deploy_path)
        @path = "#{git_repo}/#{deploy_path}"
        git("https://github.com/#{git_user}/#{git_repo}.git", git_repo, git_path)
    end

    def run
        git.pull
        servers.each do |server|
            if path = server.update_server_path
                if server.ensure == "running"
                    system("kubectl apply -f #{@path}/#{path}")
                elsif server.ensure == "stopping"
                    system("kubectl delete -f #{@path}/#{path}")
                end
            end
        end
    end

    protected

    def git(uri="", name="", path="")
        @git ||= begin
            Git.clone(uri, name, :path => path)
        rescue Git::GitExecuteError => e
            Git.open(name)
        end
    end

    def servers
        Stratus::Server.all
    end
end
