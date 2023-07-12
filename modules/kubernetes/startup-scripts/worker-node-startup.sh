#!/bin/bash


apt update -y
apt install snapd
snap install microk8s --classic
alias kubectl='microk8s kubectl'