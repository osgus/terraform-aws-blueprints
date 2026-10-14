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
    "Project"    = "glpi"
    "managed_by" = "terraform"
  }
}

variable "glpi-ami" {
  description = "AMI para a instância do GLPI"
  type        = string
  default     = "ami-0b75f821522bcff85"
}

variable "instance-type" {
  description = "Tipo de instância para o aplicativo GLPI"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome da chave SSH para acessar a instância"
  type        = string
  default     = "gustavo"
}