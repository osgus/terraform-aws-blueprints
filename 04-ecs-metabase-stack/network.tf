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

