output "instance" {
  description = "Public IP of instance"
  value = aws_instance.instance.public_ip
}

