#!/bin/bash


apt update -y

# INSTALL DOCKER

apt-get update -y
apt-get install ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# RUN MONITORING SERVICES

echo "${telegraf_config}" > /home/ubuntu/telegraf.conf
echo "${docker_compose}" > /home/ubuntu/docker-compose.yaml

docker compose -f /home/ubuntu/docker-compose.yaml up -d

# RUN SITESPEED.IO

#sleep 120
#
docker run --rm -d -v "$(pwd):/sitespeed.io" sitespeedio/sitespeed.io:27.9.0 \
  --graphite.host=host.docker.internal https://www.sephora.com/ \
  --slug sephoraTest --graphite.addSlugToKey true -n 1