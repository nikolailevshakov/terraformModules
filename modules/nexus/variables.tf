variable "region" {
  description = "Chosen region"
  type = string
  default = "us-east-1"
}


variable "vpc_cidr_block" {
  description = "Cidr block for VPC"
  type = string
  default = "10.14.14.0/24"
}

variable "subnet_cidr_block" {
  description = "Cidr block for subnet VPC"
  type = string
  default = "10.14.14.0/26"
}

variable "my_ip" {
  description = "My ip address"
  type = string
  default = "87.116.161.167"
}

variable "ami" {
  description = "AMI based on a region"
  type = map
  default = {
    "us-east-1" = "ami-053b0d53c279acc90"
    "eu-central-1" = "ami-0fa03365cde71e0ab"
    "us-west-1" = "ami-0f8e81a3da6e2510a"
  }
}

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t2.medium"
}

variable "volume_size" {
  description = "ebs root volume size in GB"
  type = number
  default = 10
}