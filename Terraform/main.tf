provider "aws" {
  access_key =  var.aws_access_key                                      # Replace with your AWS access key ID (leave empty if using IAM roles or env vars)
  secret_key =  var.aws_secret_key                                      # Replace with your AWS secret access key (leave empty if using IAM roles or env vars)
  region     =  var.region                                          # Specify the AWS region where resources will be created (e.g., us-east-1, us-west-2)
}

# VPC Module
module "vpc" {
  source   = "./modules/vpc"
  vpc_name = var.vpc_name
  vpc_id = var.vpc_id
  azs = var.azs
  frontend_instance_ids = module.ec2.frontend_instance_ids
}




# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type = var.instance_type
  ami_id        = var.ami_id
  rds_db = module.rds.rds_db
  rds_endpoint = module.rds.rds_endpoint
  public_key = file("./scripts/public_key.txt")
  db_name = module.rds.db_name
  db_username = module.rds.db_username
  db_password = var.db_password
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  backend_sg_id = module.ec2.backend_sg_id
  db_instance_class  = var.db_instance_class 
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}