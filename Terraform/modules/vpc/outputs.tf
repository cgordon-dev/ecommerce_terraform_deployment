output "vpc_name" {
  value = "wl5vpc" 
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}


output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = aws_subnet.public[*].id
}


output "private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = aws_subnet.private[*].id
}


output "internet_gateway_id" {
  description = "ID of the created Internet Gateway"
  value       = aws_internet_gateway.gw.id
}


output "nat_gateway_id" {
  description = "ID of the created NAT Gateway"
  value       = aws_nat_gateway.gw-NAT.id
}


output "nat_gateway_eip" {
  description = "Elastic IP associated with the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}


output "load_balancer_arn" {
  description = "ARN of the created Load Balancer"
  value       = aws_lb.public_lb.arn
}


output "load_balancer_dns" {
  description = "DNS name of the created Load Balancer"
  value       = aws_lb.public_lb.dns_name
}


output "load_balancer_sg_id" {
  description = "Security Group ID of the Load Balancer"
  value       = aws_security_group.lb_sg.id
}


output "target_group_arn" {
  description = "ARN of the created Target Group"
  value       = aws_lb_target_group.tg.arn
}

