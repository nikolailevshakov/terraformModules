variable "region" {
  description = "Chosen region"
  type = string
  default = "us-east-1"
}


variable "vpc_cidr_block" {
  description = "Cidr block for VPC"
  type = string
  default = "10.14.0.0/16"
}

variable "subnet_cidr_block_1" {
  description = "Cidr block for public subnet VPC"
  type = string
  default = "10.14.1.0/24"
}

variable "subnet_cidr_block_2" {
  description = "Cidr block for public subnet VPC"
  type = string
  default = "10.14.2.0/24"
}

variable "subnet_cidr_block_3" {
  description = "Cidr block for private subnet VPC"
  type = string
  default = "10.14.3.0/24"
}

variable "subnet_cidr_block_4" {
  description = "Cidr block for private subnet VPC"
  type = string
  default = "10.14.4.0/24"
}

variable "my_ip" {
  description = "My ip address"
  type = string
  default = "87.116.163.37"
}

variable "ami" {
  description = "AMI based on a region"
  type = map
  default = {
    "us-east-1" = "ami-0557a15b87f6559cf"
    "eu-central-1" = "ami-0fa03365cde71e0ab"
  }
}

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t2.micro"
}

variable "instance_amount" {
  description = "Amount of instances in target group"
  type = number
  default = 2
}