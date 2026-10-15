terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  #Altere o valor default para o bucket, key, region e profile que deseja utilizar para armazenar o remote state do Terraform
  backend "s3" {
    bucket  = "osgus-terraform-aws-blueprints"
    key     = "03-zabbix-rds-stack/terraform.state"
    region  = "us-east-1"
    profile = "terraform"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = var.default_tags
  }
}
#Altere o valor default para o bucket configurado no backend do Terraform que deseja utilizar para obter o remote state do Terraform
data "terraform_remote_state" "vpc-base" {
  backend = "s3"
  config = {
    bucket  = "osgus-terraform-aws-blueprints"
    key     = "01-vpc-base/terraform.state"
    region  = "us-east-1"
    profile = "terraform"
  }
}