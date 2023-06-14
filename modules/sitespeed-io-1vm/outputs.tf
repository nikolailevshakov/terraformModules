output "instance" {
  description = "Ip of the instance"
  value = aws_instance.instance.public_ip
}

