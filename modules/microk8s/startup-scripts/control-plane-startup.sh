#!/bin/bash


apt update -y
snap install microk8s --classic
echo "kubectl='microk8s kubectl'" >> /home/ubuntu/.bashrc
usermod -a -G microk8s ubuntu
chown -f -R ubuntu ~/.kube

microk8s add-node > /home/ubuntu/get-node.txt