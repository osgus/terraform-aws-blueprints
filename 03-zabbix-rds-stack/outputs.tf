output "alb_dns_name" {
  description = "DNS público do Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "zabbix-private-ip" {
  description = "IP Privado do Zabbix."
  value       = aws_instance.zabbix.private_ip
}

output "zabbix-db-endpoint" {
  description = "Endpoint do Banco de Dados do Zabbix."
  value       = aws_db_instance.zabbix-db.address
}