FROM stratusnetwork/minecraft:base

# Create working server directory
WORKDIR server

# Copy shared configurations
COPY . .
RUN chmod +x subst.sh

# Create plugins folder
WORKDIR plugins

# Move configs when other building is done
ONBUILD WORKDIR /minecraft/server
ONBUILD CMD ./subst.sh plugins && \
  mkdir -p plugins/API && cp api.yml plugins/API/config.yml && \
  mkdir -p plugins/API-OCN && mv api.yml plugins/API-OCN/config.yml && \
  mkdir -p plugibs/Commons && mv commons.yml plugins/Commons/config.yml