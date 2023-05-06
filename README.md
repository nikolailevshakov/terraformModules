# terraformModules
Collection of terraform modules

Ansible-key directory contains keys to control child nodes by ansible control node.
To check that module works correctly:
- ssh to control node with key.pub
- run command ansible -i ./hosts servers -m ping
