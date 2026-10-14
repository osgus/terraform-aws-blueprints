terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket  = "osgus-terraform-aws-blueprints"
    key     = "02-glpi-ec2-stack/terraform.state"
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

data "terraform_remote_state" "vpc-base" {
  backend = "s3"
  config = {
    bucket  = "osgus-terraform-aws-blueprints"
    key     = "01-vpc-base/terraform.state"
    region  = "us-east-1"
    profile = "terraform"
  }
}