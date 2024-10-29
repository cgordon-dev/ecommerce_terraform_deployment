output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = module.vpc.private_subnet_ids
}

output "frontend_instance_ids" {
  description = "IDs of the frontend EC2 instances"
  value       = module.ec2.frontend_instance_ids
}

output "backend_instance_ids" {
  description = "IDs of the backend EC2 instances"
  value       = module.ec2.backend_instance_ids
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.rds.rds_endpoint
}

output "frontend_ips" {
  value = module.ec2.frontend_instance_public_ips
}

output "backend_ips" {
  value = module.ec2.backend_instance_private_ips
  
}