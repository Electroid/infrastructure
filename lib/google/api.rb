require "googleauth"
require "google/apis/compute_beta"
require "environment"

# Represents an object that interacts with any Google API.
module Google

    # The path to the JSON credentials file.
    def credentials
        "google.json"
    end

    # Get the project ID that is specified in the credentials file.
    def project_id
        @project_id ||= Env.need("google_project_id")
    end

    # Authenticate a Google service object with a path to a JSON credentials file.
    # The environment variables 'GOOGLE_PRIVATE_KEY' and 'CLIENT_EMAIL_VAR' must
    # be defined for authentication to work properly.
    def auth(service)
        service.authorization = Google::Auth::ServiceAccountCredentials.make_creds({
            :scope => "https://www.googleapis.com/auth/compute"
        })
        service
    end
end

