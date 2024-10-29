output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.postgres_db.endpoint
}

output "rds_port" {
  description = "RDS Port"
  value       = aws_db_instance.postgres_db.port
}

output "db_password" {
  value = var.db_password
}