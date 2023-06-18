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

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = "${var.region}a"
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

resource "aws_security_group" "instance-monitoring-sg" {
  name        = "Ingress monitoring"
  description = "Allows ssh access"
  vpc_id      = aws_vpc.sample-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
#    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "instance-sitespeed-sg" {
  name        = "Ingress sitespeed"
  description = "Allows ssh access"
  vpc_id      = aws_vpc.sample-vpc.id

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
    cidr_blocks = ["${var.my_ip}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_key_pair" "key_pair" {
  key_name   = "instance-key"
  public_key = file("${path.module}/key.pub")
}

resource "aws_instance" "instance-monitoring" {
  ami                         = var.ami[var.region]
  instance_type               = var.type_monitoring_instance
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance-monitoring-sg.id]

  user_data_base64 = base64encode(templatefile("${path.module}/startup-scripts/userdata-monitoring.sh", {
    influxdb_datasource = file("${path.module}/config/influxdb_datasource.yaml"),
    influxdb_dashboard_config = file("${path.module}/config/influxdb_dashboard.yaml"),
    telegraf_config = file("${path.module}/config/telegraf.conf"),
  }))

  tags = {
    Name = "Instance-monitoring"
  }
}

#resource "aws_instance" "instance-sitespeed" {
#  ami                         = var.ami[var.region]
#  instance_type               = var.type_sitespeedio_instance
#  key_name                    = aws_key_pair.key_pair.key_name
#  associate_public_ip_address = true
#  subnet_id                   = aws_subnet.public.id
#  vpc_security_group_ids      = [aws_security_group.instance-sitespeed-sg.id]
#
#  user_data_base64 = base64encode(templatefile("${path.module}/startup-scripts/userdata-sitespeed.sh", {
#    MONITORING_INSTANCE_IP = aws_instance.instance-monitoring.public_ip,
#    telegraf_config = file("${path.module}/config/telegraf.conf"),
#  }))
#  depends_on = [aws_instance.instance-monitoring]
#  tags = {
#    Name = "Instance-sitespeed"
#  }
#}


