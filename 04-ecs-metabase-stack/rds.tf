resource "aws_security_group" "db_sg" {
  name        = "metabase-db-sg"
  description = "ECS-RDS-5432"
  vpc_id      = data.terraform_remote_state.vpc-base.outputs.vpc_id

  ingress {
    description     = "ECS-RDS-5432"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    description = "Saida para a Internet via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "metabase-db-sg"
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name = "metabase-db-subnet-group"
  subnet_ids = [
    data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-db-subnet-a"],
    data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-db-subnet-b"]
  ]

  tags = {
    Name = "metabase-db-subnet-group"
  }
}

resource "aws_db_instance" "metabase_db" {
  identifier             = "metabase-db"
  allocated_storage      = 20
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "metabase-db"
  }
}