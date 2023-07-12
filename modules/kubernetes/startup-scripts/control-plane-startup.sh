#!/bin/bash


apt update -y
apt install tree -y
apt install net-tools -y
apt install snapd
snap install microk8s --classic
alias kubectl='microk8s kubectl'
usermod -a -G microk8s ubuntu
chown -f -R ubuntu ~/.kube

microk8s add-node > /home/ubuntu/get-node.txt