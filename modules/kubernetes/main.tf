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

resource "aws_vpc" "sample_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.sample_vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sample_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sample_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_security_group" "instance" {
  name        = "SSH ingress"
  description = "Allows ssh access"
  vpc_id      = aws_vpc.sample_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
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
    Name = "SSH, TCP, ICMP - in"
  }
}


resource "aws_key_pair" "key_pair" {
  key_name   = "instance-key"
  public_key = file("${path.module}/key.pub")
}

resource "aws_key_pair" "key_pair_worker" {
  key_name   = "ansible-key"
  public_key = file("${path.module}/worker-key/worker.pub")
}

resource "aws_instance" "controle_plane" {
  ami                         = var.ami[var.region]
  instance_type               = var.controle_plane_instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]

  user_data_base64 = base64encode(templatefile("${path.module}/startup-scripts/control-plane-startup.sh", {}))

  tags = {
    Name = "Control-plane"
  }
}

resource "aws_instance" "worker_node" {
  count                       = var.worker_node_amount
  ami                         = var.ami[var.region]
  instance_type               = var.worker_node_instance_type
  key_name                    = aws_key_pair.key_pair_worker.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  tags = {
    Name = "Child-node-${count.index}"
  }
}

