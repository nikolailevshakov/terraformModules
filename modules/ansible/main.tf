terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "sample-vpc" {
  cidr_block           = "10.14.14.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = "10.14.14.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sample-vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sample-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_security_group" "instance" {
  name        = "SSH ingress"
  description = "Allows ssh access"
  vpc_id      = aws_vpc.sample-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["188.246.37.64/32"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["188.246.37.64/32"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH-in"
  }
}


resource "aws_key_pair" "key_pair" {
  key_name   = "instance-key"
  public_key = file("${path.module}/key.pub")
}

resource "aws_key_pair" "key_pair_ansible" {
  key_name   = "ansible-key"
  public_key = file("${path.module}/ansible-key/ansible.pub")
}

resource "aws_instance" "instance" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "Control-node"
  }
}

resource "aws_instance" "instance-child" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key_pair_ansible.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  count = 3
  tags = {
    Name = "Child-node-${count.index}"
  }
}
#resource "aws_instance" "instance-2" {
#  ami                         = "ami-0557a15b87f6559cf"
#  instance_type               = "t2.micro"
#  key_name                    = aws_key_pair.key_pair_ansible.key_name
#  associate_public_ip_address = true
#  subnet_id                   = aws_subnet.public.id
#  vpc_security_group_ids      = [aws_security_group.instance.id]
#
#  tags = {
#    Name = "Child-node-2"
#  }
#}
#
#resource "aws_instance" "instance-3" {
#  ami                         = "ami-0557a15b87f6559cf"
#  instance_type               = "t2.micro"
#  key_name                    = aws_key_pair.key_pair_ansible.key_name
#  associate_public_ip_address = true
#  subnet_id                   = aws_subnet.public.id
#  vpc_security_group_ids      = [aws_security_group.instance.id]
#
#  tags = {
#    Name = "Child-node-3"
#  }
#}

output "control_node_ip_addr" {
  description = "Public IP of control node"
  value = aws_instance.instance.public_ip
}

output "child_ip_addresses" {
  description = "Public IPs of child nodes"
  value = aws_instance.instance-child[*].public_ip
}

