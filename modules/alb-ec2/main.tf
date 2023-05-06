terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}

resource "aws_vpc" "sample-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = var.subnet_cidr_block_1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "subnet-2" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = var.subnet_cidr_block_2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

#resource "aws_route_table" "public_rt" {
#  vpc_id = aws_vpc.sample-vpc.id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.igw.id
#  }
#}

resource "aws_security_group" "instance" {
  name        = "ALB ingress"
  description = "Allows ingress only from alb, egress all"
  vpc_id      = aws_vpc.sample-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Egress-all, ingress-albsg"
  }
}

resource "aws_security_group" "alb" {
  name        = "ingress-all, egress-instances"
  description = "Allows all in and out to instances"
  vpc_id      = aws_vpc.sample-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Egress-instances, ingress-all"
  }
}

resource "aws_instance" "instance-1" {
  ami                         = var.ami[var.region]
  instance_type               = "t2.micro"
#  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {}))
  count = 2

  tags = {
    Name = "Group-1-node-${count.index}"
  }
}

resource "aws_instance" "instance-2" {
  ami                         = var.ami[var.region]
  instance_type               = "t2.micro"
#  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.subnet-2.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {}))
  count = 2

  tags = {
    Name = "Group-2-node-${count.index}"
  }
}



