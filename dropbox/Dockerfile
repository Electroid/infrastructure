FROM stratusnetwork/maven as build

# Build the dropbox sync client from github
ADD https://${AUTH}api.github.com/repos/StratusNetwork/dropbox-sync/git/refs/heads/master dropbox.json
RUN ./clone.sh StratusNetwork dropbox-sync master

FROM anapsix/alpine-java:8_server-jre as client

# Copy the jar file from the build stage
COPY --from=build /dropbox-sync/target/dropbox-sync-1.0-SNAPSHOT.jar dropbox.jar

# Default environment variables
ENV DROPBOX_FOLDER_LOCAL="/dropbox"
ENV DROPBOX_FOLDER_REMOTE=""
ENV DROPBOX_OAUTH_TOKEN="null"

# Run the dropbox sync java program
CMD exec java -d64 -jar dropbox.jar "$DROPBOX_OAUTH_TOKEN" "$DROPBOX_FOLDER_LOCAL" "$DROPBOX_FOLDER_REMOTE"
