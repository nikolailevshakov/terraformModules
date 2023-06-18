output "control_node_ip_addr" {
  description = "Public IP of control node"
  value = aws_instance.controle_node.public_ip
}

output "child_ip_addresses" {
  description = "Public IPs of child nodes"
  value = aws_instance.instance_child[*].public_ip
}