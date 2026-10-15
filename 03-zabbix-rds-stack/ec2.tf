resource "aws_security_group" "zabbix-app-sg" {
  name        = "zabbix-app-sg"
  description = "Security group SSH e HTTP"
  vpc_id      = data.terraform_remote_state.vpc-base.outputs.vpc_id
  tags = {
    Name = "zabbix-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "zabbix-app-sg-http" {
  security_group_id            = aws_security_group.zabbix-app-sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "zabbix-app-sg-out" {
  security_group_id = aws_security_group.zabbix-app-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "zabbix" {
  ami                    = var.zabbix-ami
  instance_type          = var.instance-type
  subnet_id              = data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-app-subnet-a"]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.zabbix-app-sg.id]
  tags = {
    Name = "zabbix"
  }

  depends_on = [aws_nat_gateway.nat, aws_db_instance.zabbix-db]
  user_data = templatefile("${path.module}/docs/zabbix.sh.tftpl", {
    db_host = aws_db_instance.zabbix-db.address
    db_name = var.db_name
    db_user = var.db_user
    db_pass = var.db_pass
  })
}