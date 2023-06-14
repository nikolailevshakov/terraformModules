#output "instance" {
#  description = "Public IP of instance"
#  value = module.instance.instance
#}

#output "child_ip_addresses" {
#  description = "Public IPs of child nodes"
#  value = module.ansible.child_ip_addresses
#}

#output "alb_dns_name" {
#  description = "DNS name of the load balancer"
#  value = module.alb-ec2.alb_dns_name
#}

#output "monitoring-instance" {
#  description = "Ip of the instance with influxdb and grafana"
#  value = module.sitespeed-io.monitoring-instance
#}

#output "sitespeed-io-agent" {
#  description = "Ip of the instance with sitespeed-io"
#  value = module.sitespeed-io.sitespeed-io-agent
#}

output "sitespeed-io-instance" {
  description = "Ip of the instance with influxdb and grafana"
  value = module.sitespeed-io-1vm.instance
}