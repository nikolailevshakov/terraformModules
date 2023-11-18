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
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  key_name   = "instance-key-ansible-controle-node"
  public_key = file("${path.module}/key.pub")
}

resource "aws_key_pair" "key_pair_ansible" {
  key_name   = "ansible-key"
  public_key = file("${path.module}/ansible-key/ansible.pub")
}

resource "aws_instance" "controle_node" {
  ami                         = var.ami[var.region]
  instance_type               = var.controle_node_instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]

  user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {
    child_public_ip1 = aws_instance.instance_child[0].public_ip
    child_public_ip2 = aws_instance.instance_child[1].public_ip
#    child_public_ip3 = aws_instance.instance_child[2].public_ip
    private_key = file("${path.module}/ansible-key/ansible")
  }))

  depends_on = [aws_instance.instance_child[0], aws_instance.instance_child[1]]
  tags = {
    Name = "Control-node"
  }
}

resource "aws_instance" "instance_child" {
  count                       = var.children_node_amount
  ami                         = var.ami[var.region]
  instance_type               = var.children_node_instance_type
  key_name                    = aws_key_pair.key_pair_ansible.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  tags = {
    Name = "Child-node-${count.index}"
  }
}

