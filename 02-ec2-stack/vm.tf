resource "aws_instance" "glpi-app" {
  ami                    = var.glpi-ami
  instance_type          = var.instance-type
  subnet_id              = data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-app-subnet-a"]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app-sg.id]
  tags = {
    Name = "glpi-app"
  }
  depends_on = [aws_nat_gateway.nat]
  user_data  = file("./docs/glpi-web.sh")
}

resource "aws_instance" "glpi-db" {
  ami                    = var.glpi-ami
  instance_type          = var.instance-type
  subnet_id              = data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-db-subnet-a"]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  tags = {
    Name = "glpi-db"
  }
  depends_on = [aws_nat_gateway.nat]
  user_data  = file("./docs/glpi-mariadb.sh")
}