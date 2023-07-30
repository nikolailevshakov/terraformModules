#!/bin/bash


apt update -y
snap install microk8s --classic
echo "alias kubectl='microk8s kubectl'" >> /home/ubuntu/.bashrc
usermod -a -G microk8s ubuntu
chown -f -R ubuntu ~/.kube
git clone https://github.com/sandervanvugt/cka /home/ubuntu/cka

microk8s add-node | head -n 2 | tail -n 1 > /home/ubuntu/add-node.sh