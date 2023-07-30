#!/bin/bash


apt update -y
snap install microk8s --classic
echo "alias kubectl='microk8s kubectl'" >> /home/ubuntu/.bashrc
echo "${private_key}" > /home/ubuntu/.ssh/id_rsa
usermod -a -G microk8s ubuntu
chown -f -R ubuntu ~/.kube
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@"${control_node_ip}":/home/ubuntu/add-node.sh /home/ubuntu
chmod +x /home/ubuntu/add-node.sh
/home/ubuntu/add-node.sh