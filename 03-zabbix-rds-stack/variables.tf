#Altere o valor default para o perfil da AWS que deseja utilizar
variable "aws_profile" {
  description = "Perfil da AWS a ser utilizado"
  type        = string
  default     = "terraform"
}
# Altere o valor default para o a região que deseja utilizar
variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"

}
#Altere o valor default para o as tags que deseja utilizar
variable "default_tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default = {
    "Owner"      = "gustavo"
    "Project"    = "zabbix"
    "managed_by" = "terraform"
  }
}
#Altere o valor default para a AMI que deseja utilizar para a instância do Zabbix
variable "zabbix-ami" {
  description = "AMI para a instância do Zabbix"
  type        = string
  default     = "ami-0b75f821522bcff85"
}

#Altere o valor default para alterar o tipo de instância que deseja utilizar para a instância do Zabbix
variable "instance-type" {
  description = "Tipo de instância para o aplicativo Zabbix"
  type        = string
  default     = "t3.micro"
}

#Altere o valor default para alterar o nome da instancia do banco
variable "identifier" {
  description = "Identificador do banco de dados"
  type        = string
  default     = "zabbix-db"
}

#Altere o valor default para alterar a chave SSH que deseja utilizar para acessar a instância do Zabbix
variable "key_name" {
  description = "Nome da chave SSH para acessar a instância"
  type        = string
  default     = "gustavo"
}

#Altere o valor default para alterar a classe da instância do banco de dados que deseja utilizar
variable "db_instance_class" {
  description = "Classe da instância do banco de dados"
  type        = string
  default     = "db.t4g.micro"
}

#Altere o valor default para alterar o nome do usuario do banco de dados que deseja utilizar
variable "db_username" {
  description = "Nome de usuário do banco de dados"
  type        = string
  default     = "zabbix"
}

#Altere o valor default para alterar a senha do banco de dados que deseja utilizar
variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  default     = "Amarelo0!"
}

#Altere o valor default para alterar o nome do banco de dados que deseja utilizar
variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "zabbix"
}

#Altere o valor default para alterar o espaço alocado para o banco de dados que deseja utilizar
variable "db_allocated_storage" {
  description = "Armazenamento alocado para o banco de dados (em GB)"
  type        = number
  default     = 20
}

#Altere o valor default para alterar a engine do banco de dados que deseja utilizar
variable "db_engine" {
  description = "Motor do banco de dados"
  type        = string
  default     = "mysql"
}

#Altere o valor default para alterar a versão do motor do banco de dados que deseja utilizar
variable "db_engine_version" {
  description = "Versão do motor do banco de dados"
  type        = string
  default     = "8.4.11"
}

#Altere para o valor default o nome do usuario do banco de dados que deseja utilizar
variable "db_user" {
  description = "Nome de usuário do banco de dados"
  type        = string
  default     = "zabbix"
}

#Altere para o valor default a senha do usuario do banco de dados que deseja utilizar
variable "db_pass" {
  description = "Senha do banco de dados"
  type        = string
  default     = "Amarelo0!"
}
