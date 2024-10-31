variable "key_name" {
  description = "The SSH key name for EC2 instances"
  type        = string
  default = "wl5-key"
}

variable "db_instance_class" {
  description = "The type of database instance"
  default = "db.t3.micro"
}
variable "db_name" {
  description = "The database name for the RDS instance"
  type        = string
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "ami_id" {
}

variable "instance_type" {
}

variable "vpc_name" {
  default = "wl5vpc"
  
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  
  
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}

variable "aws_access_key" {
  sensitive = true
  
}

variable "aws_secret_key" {
  sensitive = true
  
}

variable "region" {
  default = "us-east-1"
  
}