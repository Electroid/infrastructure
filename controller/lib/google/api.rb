require "googleauth"
require "google/apis/compute_beta"

# Represents an object that interacts with any Google API.
module Google

    # The path to the JSON credentials file.
    def credentials
        "google.json"
    end

    # Get the project ID that is specified in the credentials file.
    def project_id
        @project_id ||= JSON.parse(File.read(credentials))["project_id"]
    end

    # Authenticate a Google service object with a path to a JSON credentials file.
    def auth(service)
        service.authorization = Google::Auth::ServiceAccountCredentials.make_creds({
            :json_key_io => File.open(credentials, "r"),
            :scope => "https://www.googleapis.com/auth/compute"
        })
        service
    end
end

