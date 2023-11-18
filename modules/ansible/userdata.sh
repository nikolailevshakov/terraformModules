#!/bin/bash


apt update -y
apt install tree -y
apt install net-tools -y
echo "${private_key}" > /home/ubuntu/.ssh/id_rsa
chmod 0400 id_rsa
apt install ansible -y
echo "
[servers]
host1 ansible_host=${child_public_ip1}
host2 ansible_host=${child_public_ip2}" > /home/ubuntu/hosts

# use ansible -i ./hosts servers -m ping - to ping children nodes