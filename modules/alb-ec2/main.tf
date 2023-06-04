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

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = var.subnet_cidr_block_1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = var.subnet_cidr_block_2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = var.subnet_cidr_block_3
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = var.subnet_cidr_block_4
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
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

resource "aws_eip" "nat_gateway" {
  vpc = true
  associate_with_private_ip = "10.14.0.5"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public-subnet-1.id

  depends_on = [aws_eip.nat_gateway]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.sample-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
}

resource "aws_route_table_association" "route_table_ass_subnet-1" {
  subnet_id = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "route_table_ass_subnet-2" {
  subnet_id = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "route_table_ass_subnet-3" {
  subnet_id = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "route_table_ass_subnet-4" {
  subnet_id = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "instance" {
  name        = "ALB ingress"
  description = "Allows ingress only from alb, egress all"
  vpc_id      = aws_vpc.sample-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
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
#    security_groups = [aws_security_group.instance.id]
  }

  tags = {
    Name = "Egress-instances, ingress-all"
  }
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "elb_account_id" {}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "loadbalancer-logs-04071993"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = data.aws_iam_policy_document.allow_lb.json
}

data "aws_iam_policy_document" "allow_lb" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]
    actions = ["s3:PutObject"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.elb_account_id.id}:root"]
    }
  }

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}",
    ]
    actions = ["s3:GetBucketAcl"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    enabled = true
  }

  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "tg-1" {
  name     = "instance-tg-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.sample-vpc.id
}

resource "aws_lb_target_group_attachment" "tg_attachment-1" {
  count            = length(aws_instance.instance-1)
  target_group_arn = aws_lb_target_group.tg-1.arn
  target_id        = aws_instance.instance-1[count.index].id
  port             = 80
}

resource "aws_lb_target_group" "tg-2" {
  name     = "instance-tg-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.sample-vpc.id
}

resource "aws_lb_target_group_attachment" "tg_attachment-2" {
  count            = length(aws_instance.instance-2)
  target_group_arn = aws_lb_target_group.tg-2.arn
  target_id        = aws_instance.instance-2[count.index].id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.tg-1.arn
      }
      target_group {
        arn = aws_lb_target_group.tg-2.arn
      }
    }
  }
}

resource "aws_instance" "instance-1" {
  ami                         = var.ami[var.region]
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private-subnet-1.id
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
  subnet_id                   = aws_subnet.private-subnet-2.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {}))
  count = 2

  tags = {
    Name = "Group-2-node-${count.index}"
  }
}



