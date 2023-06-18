Module creates:
- One control node with configured ansible
- 3 child nodes

Ansible-key directory contains keys to control child nodes by ansible control node.
To check that module works correctly:
- ssh to control node with key.pem
- run command ansible -i ./hosts servers -m ping

Issues:
- Refactor of userdata.sh to use for any amount of child nodes 
- the same for the depends_on on control node (it's not allowed to use dynamic variable)