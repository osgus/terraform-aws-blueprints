#Altere o valor default para o perfil da AWS que deseja utilizar
variable "aws_profile" {
  description = "Perfil da AWS a ser utilizado"
  type        = string
  default     = "terraform"
}

#Altere o valor default para a região que deseja utilizar
variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"

}

#Altere o valor default para as tags que deseja utilizar
variable "default_tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default = {
    "Owner"      = "gustavo"
    "Project"    = "glpi"
    "managed_by" = "terraform"
  }
}

#Altere o valor default para a AMI que deseja utilizar
variable "glpi-ami" {
  description = "AMI para a instância do GLPI"
  type        = string
  default     = "ami-0b75f821522bcff85"
}

#Altere o valor default para o tipo de instância que deseja utilizar
variable "instance-type" {
  description = "Tipo de instância para o aplicativo GLPI"
  type        = string
  default     = "t3.micro"
}

#Altere o valor default para o nome da chave SSH que deseja utilizar
variable "key_name" {
  description = "Nome da chave SSH para acessar a instância"
  type        = string
  default     = "gustavo"
}