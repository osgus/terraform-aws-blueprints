resource "aws_security_group" "rds-mysql-sg" {
  name        = "rds-mysql-sg"
  description = "Security group RDS MySQL"
  vpc_id      = data.terraform_remote_state.vpc-base.outputs.vpc_id
  tags = {
    Name = "rds-mysql-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds-mysql-sg-mariadb" {
  security_group_id = aws_security_group.rds-mysql-sg.id

  referenced_security_group_id = aws_security_group.zabbix-app-sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}


resource "aws_vpc_security_group_egress_rule" "rds-mysql-sg-out" {
  security_group_id = aws_security_group.rds-mysql-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "zabbix-rds-subnet-group"
  description = "DB Subnet Group para o RDS MySQL nas subnets privadas"
  subnet_ids = [
    data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-db-subnet-a"],
    data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-db-subnet-b"]
  ]

  tags = {
    Name = "zabbix-rds-subnet-group"
  }
}

resource "aws_db_parameter_group" "mysql_pg" {
  name        = "zabbix-mysql-pg"
  family      = "mysql8.4"
  description = "Parameter group para desativar require_secure_transport para o Zabbix"

  parameter {
    name  = "require_secure_transport"
    value = "0"
  }

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_bin"
  }


}

resource "aws_db_instance" "zabbix-db" {
  allocated_storage = var.db_allocated_storage
  identifier        = var.identifier
  db_name           = var.db_name
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  username          = var.db_username
  password          = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.mysql_pg.name
  vpc_security_group_ids = [aws_security_group.rds-mysql-sg.id]
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true

  tags = {
    Name = "zabbix-db"
  }
}
