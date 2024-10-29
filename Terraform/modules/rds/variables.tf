variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "ecommercedb"
  
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "kurac5user"
  sensitive = true
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  default     = "kurac5password"
  sensitive = true
}

variable "vpc_id" {
  
}

variable "private_subnet_ids" {
  
}

variable "backend_sg_id" {
  
}