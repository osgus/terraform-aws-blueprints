resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "eip-nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = data.terraform_remote_state.vpc-base.outputs.subnet_ids["pub-subnet-a"]

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route" "private_internet_access" {
  route_table_id         = data.terraform_remote_state.vpc-base.outputs.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}


resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  description = "Security group SSH e HTTP"
  vpc_id      = data.terraform_remote_state.vpc-base.outputs.vpc_id
  tags = {
    Name = "app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app-sg-http" {
  security_group_id            = aws_security_group.app-sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "app-sg-out" {
  security_group_id = aws_security_group.app-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  description = "Security group DB e SSH"
  vpc_id      = data.terraform_remote_state.vpc-base.outputs.vpc_id
  tags = {
    Name = "db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db-sg-mariadb" {
  security_group_id = aws_security_group.db-sg.id

  referenced_security_group_id = aws_security_group.app-sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "db-sg-ssh" {
  security_group_id            = aws_security_group.db-sg.id
  referenced_security_group_id = aws_security_group.app-sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "db-sg-out" {
  security_group_id = aws_security_group.db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}