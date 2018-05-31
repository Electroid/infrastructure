require "worker"
require "github"
require "fileutils"

# Keeps a Github repo in sync with a local directory.
class RepoWorker < Worker
    include Github

    template(
        repo:   nil,      # Git repo (ie. Electroid/infrastructure)
        branch: "master", # Git branch
        dir:    "data",   # Git directory
        hook:   "pwd"     # Hook command (ie. curl http://example.com/webhook)
    )

    def initialize(repo, branch, path, hook=nil)
        @repo = repo
        @path = File.expand_path(path)
        @parent_path = File.dirname(@path)
        @name = File.basename(@path)
        @uri = "https://#{github_key}:x-oauth-basic@github.com/#{repo}.git"
        @branch = branch
        @hook = hook
        clone
    end

    def run
        hook if update? && pull
    end

    # Called after successful update of repository.
    def hook
        log("Updated #{@repo} to '#{%x(git log --oneline -1).strip}'")
        execute(@hook, false)
    end

    protected

    # Has the remote branch been updated?
    def update?
        previous = @pulled_at
        @pulled_at = github.repo(@repo)[:pushed_at]
        previous != @pulled_at
    end

    # Pull the latest changes from the remote branch.
    def pull
        execute("git fetch --depth 1") &&
        execute("git reset --hard origin/#{@branch}") &&
        execute("git clean -dfx")
    end

    # Initially clone or fix the repository before pull.
    def clone
        FileUtils.mkdir_p(@parent_path)
        if Dir.exist?(@path)
            if !Dir.exist?(File.join(@path, ".git"))
                log("Removing empty repository")
            elsif @uri != (uri = %x(cd #{@path} && git config --get remote.origin.url).strip)
                log("Removing another repository: #{uri.spit("/").last.split(".").first}")
            elsif @branch != (branch = %(cd #{@path} && git symbolic-ref --short -q HEAD).strip)
                log("Removing another branch: #{branch}")
            else
                valid = true
                log("Found valid repository: #{@name}")
            end
            FileUtils.rm_rf(@path) unless valid
        elsif execute("git clone --single-branch --depth 1 -b #{@branch} #{@uri} #{@path}")
            log("Cloned initial repository: #{@name}")
        else
            log("Failed to clone initial repository: #{@uri}")
            exit(1)
        end
        Dir.chdir(@path)
    end

    # Execute a shell command or exit the program if a failure occurs.
    def execute(cmd, fails=true)
        unless system("#{cmd}", :out => File::NULL)
            log("Error executing shell command: '#{cmd}'")
            exit(1) if fails
        end
        true
    end
end
