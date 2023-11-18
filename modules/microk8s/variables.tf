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
  default = "87.116.161.54"
}

variable "ami" {
  description = "AMI based on a region"
  type = map
  default = {
    "us-east-1" = "ami-0557a15b87f6559cf"
    "eu-central-1" = "ami-0fa03365cde71e0ab"
  }
}

variable "controle_plane_instance_type" {
  description = "Instance type of the control plane"
  type = string
  default = "t2.medium"
}

variable "worker_node_instance_type" {
  description = "Instance type of the worker node"
  type = string
  default = "t2.medium"
}

variable "worker_node_amount" {
  description = "Amount of worker nodes"
  type = number
  default = 1
}
