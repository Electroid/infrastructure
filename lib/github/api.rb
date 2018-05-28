require "git"
require "octokit"
require "environment"

# Extension for objects from the Github API.
module Github
    Octokit.auto_paginate = true

    def github
        @github ||= Octokit::Client.new(access_token: github_key)
    end

    def github_key
        @github_key ||= Env.need("github_key")
    end
end
