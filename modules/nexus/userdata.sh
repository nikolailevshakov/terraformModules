#!/bin/bash


apt update -y
apt install openjdk-8-jre-headless -y

wget https://download.sonatype.com/nexus/3/nexus-3.58.1-02-unix.tar.gz -O /home/ubuntu/nexus.tar.gz
tar -xvzf /home/ubuntu/nexus.tar.gz -C /home/ubuntu
/home/ubuntu/nexus-3.58.1-02/bin/nexus start
