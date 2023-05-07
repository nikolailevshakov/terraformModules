output "instance" {
  description = "Public IP of instance"
  value = aws_instance.myinstance.public_ip
}

