output "frontend_instance_ids" {
  description = "IDs of the frontend instances"
  value       = aws_instance.frontend[*].id
}

output "frontend_instance_public_ips" {
  description = "Public IPs of the frontend instances"
  value       = aws_instance.frontend[*].public_ip
}

output "backend_instance_ids" {
  description = "IDs of the backend instances"
  value       = aws_instance.backend[*].id
}

output "backend_instance_private_ips" {
  description = "Private IPs of the backend instances"
  value       = aws_instance.backend[*].private_ip
}

# Output for the Frontend Security Group ID
output "frontend_sg_id" {
  description = "ID of the frontend security group"
  value       = aws_security_group.frontend_sg.id
}

# Output for the Backend Security Group ID
output "backend_sg_id" {
  description = "ID of the backend security group"
  value       = aws_security_group.backend_sg.id
}