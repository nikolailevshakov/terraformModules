#!/bin/bash


apt update -y
apt install jq -y
wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0-amd64.deb
dpkg -i influxdb2-2.7.0-amd64.deb
service influxdb start

wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.7.3-linux-amd64.tar.gz
tar xvzf influxdb2-client-2.7.3-linux-amd64.tar.gz
cp influx /usr/local/bin/

influx setup --username admin --password adminadmin --org local -bucket default -f
influx auth list -u admin --hide-headers --json | jq '.[0].token' > influx_token.txt
export INFLUX_TOKEN=$${echo influx_token.txt}

apt-get install -y apt-transport-https
apt-get install -y software-properties-common
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list

apt-get update
apt-get install grafana
systemctl start grafana-server


cat << EOF > /etc/grafana/grafana.ini
apiVersion: 1

datasources:
  - name: InfluxDB_v2_Flux
    type: influxdb
    access: proxy
    url: http://localhost:8086
    jsonData:
      version: Flux
      organization: local
      defaultBucket: default
      tlsSkipVerify: true
    secureJsonData:
      token: $INFLUX_TOKEN
EOF

chmod 600 ~/.ssh/authorized_keys
chmod 644 ~/.ssh/id_rsa.pub