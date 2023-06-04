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

#module "ansible" {
#  source = "./modules/ansible"
#}

module "instance" {
  source = "./modules/instance"
}

#module "alb-ec2" {
#  source = "./modules/alb-ec2"
#}