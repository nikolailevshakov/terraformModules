#!/bin/bash


apt update -y
git clone https://github.com/sandervanvugt/cka /home/ubuntu/cka
/home/ubuntu/cka/setup-container.sh
/home/ubuntu/cka/setup-kubetools.sh