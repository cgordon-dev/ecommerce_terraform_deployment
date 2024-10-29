variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default = "wl5vpc"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "frontend_instance_ids" {
  
}

variable "default_vpc_id" {
  description = "The default vpc id"
  type        = string
  default     = "vpc-019a5079ad63bbc37"
}

variable "default_route_table_id" {
  description = "The default VPC's main route table id"
  type = string
  default = "rtb-08e9b621d07c9908f"
}