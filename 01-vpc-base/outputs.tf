output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc-base.id
}

output "subnet_ids" {
  description = "Mapa contendo os nomes e IDs das subnets criadas"
  value       = { for k, v in aws_subnet.subnets : k => v.id }
}