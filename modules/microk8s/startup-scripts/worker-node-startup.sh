#!/bin/bash


apt update -y
snap install microk8s --classic
alias kubectl='microk8s kubectl'
usermod -a -G microk8s ubuntu
chown -f -R ubuntu ~/.kube