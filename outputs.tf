#output "alb_dns_name" {
#  description = "DNS name of the load balancer"
#  value = module.alb-ec2.alb_dns_name
#}

#output "control_node_ip" {
#  description = "Control's node IP"
#  value       = module.ansible.control_node_ip_addr
#}

output "instance" {
  description = "Public IP of instance"
  value = module.instance.instance
}

#output "monitoring-instance" {
#  description = "Ip of the instance with influxdb and grafana"
#  value = module.sitespeed-io.monitoring-instance
#}

#output "sitespeed-io-instance" {
#  description = "Ip of the instance with influxdb and grafana"
#  value = module.sitespeed-io-1vm.instance
#}

#output "instance" {
#  description = "Public IP of instance"
#  value = module.prometheus.instance
#}

#output "instance" {
#  description = "Public IP of instance"
#  value = module.jenkins.instance
#}

#output "control-plane" {
#  description = "Public IP of instance"
#  value = module.microk8s.control_node_ip_addr
#}
#
#output "worker-nodes" {
#  description = "Public IP of instance"
#  value = module.microk8s.child_ip_addresses
#}

#output "nexus" {
#  description = "Public IP of instance"
#  value = module.nexus.instance
#}