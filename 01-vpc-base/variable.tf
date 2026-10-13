variable "aws_profile" {
  description = "Perfil da AWS a ser utilizado"
  type        = string
  default     = "terraform"
}

variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"

}

variable "default_tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default = {
    "Owner"      = "gustavo"
    "managed_by" = "terraform"
  }
}

variable "subnets" {
  description = "Configuração das subnets da VPC"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    is_public         = bool
  }))
  default = {
    "pub-subnet-a" = {
      cidr_block        = "172.16.10.0/24"
      availability_zone = "us-east-1a"
      is_public         = true
    }
    "pub-subnet-b" = {
      cidr_block        = "172.16.20.0/24"
      availability_zone = "us-east-1b"
      is_public         = true
    }
    "priv-app-subnet-a" = {
      cidr_block        = "172.16.11.0/24"
      availability_zone = "us-east-1a"
      is_public         = false
    }
    "priv-app-subnet-b" = {
      cidr_block        = "172.16.21.0/24"
      availability_zone = "us-east-1b"
      is_public         = false
    }
    "priv-db-subnet-a" = {
      cidr_block        = "172.16.12.0/24"
      availability_zone = "us-east-1a"
      is_public         = false
    }
    "priv-db-subnet-b" = {
      cidr_block        = "172.16.22.0/24"
      availability_zone = "us-east-1b"
      is_public         = false
    }
  }
}