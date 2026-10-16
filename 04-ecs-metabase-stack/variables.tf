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
    "Project"    = "metabase"
    "managed_by" = "terraform"
  }
}

variable "metabase_cpu" {
  description = "CPU Task Fargate"
  type        = string
  default     = "1024"
}

variable "metabase_memory" {
  description = "Memória Task Fargate"
  type        = string
  default     = "2048"
}

#Altere o valor default para alterar o nome da instancia do banco
variable "identifier" {
  description = "Identificador do banco de dados"
  type        = string
  default     = "metabase-db"
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
  default     = "metabase"
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
  default     = "metabase"
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
  default     = "postgres"
}

#Altere o valor default para alterar a versão do motor do banco de dados que deseja utilizar
variable "db_engine_version" {
  description = "Versão do motor do banco de dados"
  type        = string
  default     = "18.6"
}