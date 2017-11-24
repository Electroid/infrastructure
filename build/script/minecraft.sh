#! /bin/bash

set -x
cd /images

cd minecraft && docker build --build-arg "AUTH=b5254f0713d53a655992fd144f0e330264f55025:x-oauth-basic@" -t stratusnetwork/minecraft:base .
docker push stratusnetwork/minecraft:base

cd shared && docker build -t stratusnetwork/minecraft:shared .
docker push stratusnetwork/minecraft:shared

cd ../bukkit && docker build -t stratusnetwork/minecraft:bukkit .
docker push stratusnetwork/minecraft:bukkit

cd ../bungee && docker build -t stratusnetwork/minecraft:bungee .
docker push stratusnetwork/minecraft:bungee

cd ../cloudy && docker build -t stratusnetwork/minecraft:cloudy .
docker push stratusnetwork/minecraft:cloudy
