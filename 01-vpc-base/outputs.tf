output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc-base.id
}

output "subnet_ids" {
  description = "Mapa contendo os nomes e IDs das subnets criadas"
  value       = { for k, v in aws_subnet.subnets : k => v.id }
}

output "public_route_table_id" {
  description = "ID da tabela de rotas publica"
  value       = aws_route_table.rtb-public.id
}

output "private_route_table_id" {
  description = "ID da tabela de rotas privada"
  value       = aws_route_table.rtb-private.id
}