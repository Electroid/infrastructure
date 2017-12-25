FROM node:alpine

# Install the minecraft node depdencies
RUN npm install minecraft-protocol sync-request deasync merge system-sleep

# Copy javascript files into the container
COPY . .

# Run the server daemon
CMD npm start
