# Definição da VPC
resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"
  region     = var.aws_region
  tags = {
    Name = "vpc-base"
  }
}

#Definição das subnets pre configuradas no variable.tf
resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.key
  }
}

#Definição do Internet Gateway
resource "aws_internet_gateway" "igw-vpc" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-vpc"
  }
}

#Definição da tabela de rotas usada pelas subnets públicas
resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc.id
  }
  route {
    cidr_block = "172.16.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "rtb-public"
  }
}

#Definição da tabela de rotas usada pelas subnets privadas
#OBS: A tabela de rotas privada não possui rota para a internet, caso precise acessar a internet, será necessário criar um NAT Gateway e adicionar a rota, mas oriento a criar o nategateay e incrementar a rota no projeto em que for trabalhar, pois o elastic ip necessario para o nat gateway gera custo adicional.
resource "aws_route_table" "rtb-private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "172.16.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "rtb-private"
  }
}

#Definição da associação das subnets públicas com a tabela de rotas pública
resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in var.subnets : k => v if v.is_public
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.rtb-public.id
}

#Definição da associação das subnets privadas com a tabela de rotas privada
resource "aws_route_table_association" "private" {
  for_each = {
    for k, v in var.subnets : k => v if !v.is_public
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.rtb-private.id
}