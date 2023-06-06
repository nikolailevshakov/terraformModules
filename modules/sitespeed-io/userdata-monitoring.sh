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

# RUN INFLUXB

docker run -d --name influxdb -p 8086:8086 --volume $PWD/influxdb:/var/lib/influxdb2 influxdb:2.7.0
sleep 5
docker exec influxdb bash -c "influx setup --username admin --password adminadmin --org local -bucket default -f"
docker exec influxdb bash -c "influx auth list -u admin --hide-headers --json | grep token | cut -c 13-100 > influx_token.txt"

docker cp influxdb:/influx_token.txt /home/ubuntu/influxdb_token.txt
export INFLUXDB_TOKEN=$$(cat influxdb)

# RUN GRAFANA

docker run -d --name grafana -p 3000:3000 grafana/grafana-oss


#systemctl start grafana-server
#
#
#cat << EOF > /etc/grafana/grafana.ini
#apiVersion: 1
#
#datasources:
#  - name: InfluxDB_v2_Flux
#    type: influxdb
#    access: proxy
#    url: http://localhost:8086
#    jsonData:
#      version: Flux
#      organization: local
#      defaultBucket: default
#      tlsSkipVerify: true
#    secureJsonData:
#      token: $INFLUX_TOKEN
#EOF
