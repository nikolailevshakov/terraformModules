output "monitoring-instance" {
  description = "Ip of the instance with influxdb and grafana"
  value = aws_instance.instance-monitoring.public_ip
}

#output "sitespeed-io-agent" {
#  description = "Ip of the instance with sitespeed-io"
#  value = aws_instance.instance-sitespeed.public_ip
#}

