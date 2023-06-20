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

#module "alb-ec2" {
#  source = "./modules/alb-ec2"
#}

#module "ansible" {
#  source = "./modules/ansible"
#}

#module "instance" {
#  source = "./modules/instance"
#}

#module "sitespeed-io" {
#  source = "./modules/sitespeed-io"
#}

#module "sitespeed-io-1vm" {
#  source = "./modules/sitespeed-io-1vm"
#}

module "prometheus" {
  source = "./modules/prometheus"
}