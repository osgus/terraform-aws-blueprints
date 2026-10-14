output "alb_dns_name" {
  description = "DNS público do Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "glpi-public-ip" {
  description = "IP Privado da Aplicação GLPI."
  value       = aws_instance.glpi-app.private_ip
}

output "glpi-private-db-ip" {
  description = "IP Privado do Banco de Dados do GLPI."
  value       = aws_instance.glpi-db.private_ip
}