terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

#Altere os valores abaixo para o bucket S3, chave e região do backend remoto
  backend "s3" {
    bucket  = "osgus-terraform-aws-blueprints"
    key     = "01-vpc-base/terraform.state"
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