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

docker network create -d bridge sitespeed-net

# RUN TELEGRAF

export INFLUXDB_HOST=localhost
export INFLUXDB_ORG=local
export INFLUXDB_BUCKET=default
export INFLUXDB_TOKEN=

echo "${telegraf_config}" > /home/ubunut/telegraf.conf

envsubst < telegraf.conf

docker run -d --name=telegraf \
      -v /home/ubuntu/telegraf.conf:/etc/telegraf/telegraf.conf \
      telegraf

# RUN SITESPEED.IO

docker run --rm -v "$(pwd):/sitespeed.io" \
  --net sitespeed-net sitespeedio/sitespeed.io:25.4.0 \
  --influxdb.host=${MONITORING_INSTANCE_IP}:8086 https://www.sephora.com \
  --slug sephoraTest
