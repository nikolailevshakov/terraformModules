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

# RUN INFLUXDB

docker network create -d bridge monitoring

docker run -d --name influxdb -p 8086:8086 --net=monitoring --volume $PWD/influxdb:/var/lib/influxdb2 influxdb:2.7.0
sleep 5
docker exec influxdb bash -c "influx setup --username admin --password adminadmin --org local -bucket default -f"
docker exec influxdb bash -c "influx auth list -u admin --hide-headers --json | grep token | cut -c 13-100 > influxdb_token.txt"

docker cp influxdb:/influxdb_token.txt /home/ubuntu/

export INFLUXDB_TOKEN="$(cat /home/ubuntu/influxdb_token.txt)"


# RUN GRAFANA

echo "${grafana_config}" > /home/ubuntu/default.yaml
envsubst < default.yaml

docker run -d --name grafana -p 3000:3000 -v /home/ubuntu/default.yaml:/etc/grafana/provisioning/datasources/default.yaml --net=monitoring grafana/grafana-oss



