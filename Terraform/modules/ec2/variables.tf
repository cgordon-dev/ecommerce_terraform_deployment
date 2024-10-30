variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ami_id" {
  default = "ami-0866a3c8686eaeeba"
  
}
variable "instance_type" {
  default = "t3.micro"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_key" {
  description = "SSH public key to be added to the authorized_keys"
  type        = string
}

variable "rds_db" {

}

variable "rds_endpoint" {
}

variable "db_name" {
}

variable "db_username" {
}

variable "db_password" {
    description = "password for db user"
    type = string
    sensitive = true
}