#! /bin/bash

set -x
cd /images

docker build --build-arg "AUTH=b5254f0713d53a655992fd144f0e330264f55025:x-oauth-basic@" -t stratusnetwork/web .
docker push stratusnetwork/web

# docker build --build-arg "AUTH=b5254f0713d53a655992fd144f0e330264f55025:x-oauth-basic@" --build-arg "BRANCH=staging" -t stratusnetwork/web:staging .
# docker push stratusnetwork/web:staging
