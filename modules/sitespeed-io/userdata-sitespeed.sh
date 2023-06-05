#!/bin/bash


apt update -y


docker run --rm -v "${pwd}:/sitespeed.io" /
  --net sitespeed-net sitespeedio/sitespeed.io:25.4.0 /
  --influxdb.host=${MONITORING_INSTANCE_IP} https://www.sephora.com /
  --slug sephoraTest
