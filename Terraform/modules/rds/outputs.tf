output "rds_db" {
  value = aws_db_instance.postgres_db.id
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.postgres_db.endpoint
}

output "rds_port" {
  description = "RDS Port"
  value       = aws_db_instance.postgres_db.port
}

output "db_name" {
  value = var.db_name
}
output "db_username" {
  value = var.db_username
}
output "db_password" {
  value = var.db_password
}