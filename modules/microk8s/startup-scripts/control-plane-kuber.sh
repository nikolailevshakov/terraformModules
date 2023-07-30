#!/bin/bash


apt update -y
git clone https://github.com/sandervanvugt/cka /home/ubuntu/cka
/home/ubuntu/cka/setup-container.sh
sudo /home/ubuntu/cka/setup-kubetools.sh
kubeadm init | tail -1 > /home/ubuntu/add_worker_node.txt
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown "$(id -u):$(id -g) $HOME/.kube/config"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

