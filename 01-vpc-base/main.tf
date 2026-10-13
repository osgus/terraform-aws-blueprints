terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket  = "osgus-terraform-aws-blueprints"
    key     = "terraform.state"
    region  = "us-east-1"
    profile = "terraform"
  }

}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = var.default_tags
  }
}