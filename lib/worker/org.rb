require "worker"
require "git"

# Add members of a Github orginization as collaborators to an external repository.
class OrgWorker < Worker
    include Github

    ADMIN   = "Administrators"
    DEV     = "Developers"
    JR_DEV  = "Junior Developers"
    MAP_DEV = "Map Developers"
    ALL     = [ADMIN, DEV, JR_DEV, MAP_DEV]

    instance(
        "StratusNetwork",
        [
            {repo: "Electroid/maps", teams: ALL},
            {repo: "Electroid/plugins", teams: [ADMIN, DEV, JR_DEV]},
            {repo: "Electroid/infrastructure", teams: [ADMIN, DEV]}
        ],
        every: 1.day
    )

    def initialize(org, data)
        @org = github.org(org)
        @teams = github.org_teams(@org[:id]).map{|team| [team[:name], team]}.to_h
        @data = data.map do |data|
            unless data.key?(:teams) && data.key?(:repo)
                raise "Unable to parse #{data}, must have 'teams' and 'repo' keys"
            end
            {
                repo: (github.repo(data[:repo]) or raise "Unable to find repo '#{data[:repo]}'"),
                teams: data[:teams].map{|team| @teams[team] or raise "Unable to find team '#{team}'"}
            }
        end
    end

    def run
        @members = @teams.map{|name, team| [name, github.team_members(team[:id]).map(&:login)]}.to_h
        @data.each do |data|
            repo = data[:repo]
            teams = data[:teams]
            collaborators = github.collaborators(repo[:id]).map(&:login)
            members = teams.flat_map{|team| @members[team[:name]]}.uniq
            (members - collaborators).each do |add|
                log("Adding #{add} to #{repo[:name]}")
                github.add_collaborator(repo[:id], add)
            end
            (collaborators - members).each do |remove|
                log("Removing #{remove} from #{repo[:name]}")
                github.remove_collaborator(repo[:id], remove)
            end
        end
    end
end
