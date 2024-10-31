resource "aws_instance" "backend" {
  count             = 2
  ami               = var.ami_id 
  instance_type     = var.instance_type
  subnet_id         = element(var.private_subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name          = aws_key_pair.ssh_key_pair.key_name
  user_data         = templatefile("${path.root}/scripts/backend_setup.sh",{
    public_key = var.public_key,
    db_name = var.db_name
    db_username = var.db_username
    db_password = var.db_password,
    rds_endpoint = var.rds_endpoint})



 /*  user_data = templatefile("${path.root}/scripts/backend_setup.sh.tpl", {
    private_ip = ""
  }) */
  
  
  
  tags = {
    Name = "ecommerce_backend_az${count.index + 1}"
  }

  # Depends on RDS Instance to be created.
  depends_on = [var.rds_db]


}



resource "aws_instance" "frontend" {
  count             = 2
  ami               = var.ami_id  
  instance_type     = var.instance_type
  subnet_id         = element(var.public_subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  key_name          = aws_key_pair.ssh_key_pair.key_name
  user_data         = templatefile("${path.root}/scripts/frontend_setup.sh", {
     public_key = var.public_key,
     BACKEND_PRIVATE_IP = aws_instance.backend[count.index].private_ip, 
     private_ip = aws_instance.backend[count.index].private_ip})

  
/*   user_data = templatefile("${path.root}/scripts/frontend_setup.sh.tpl", {
    backend_private_ip = aws_instance.backend[count.index].private_ip
  }) */

  tags = {
    Name = "ecommerce_frontend_az${count.index + 1}"
  }

# Ensure frontend instances depend on the backend instances being created
  depends_on = [aws_instance.backend]

}



resource "aws_security_group" "frontend_sg" {
  vpc_id     = var.vpc_id
  name        = "frontend_sg"
  description = "traffic to frontend server"
  # Ingress rules: Define inbound traffic that is allowed.Allow SSH traffic and HTTP traffic on port 8080 from any IP address (use with caution)
  
  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #to view frontend sever
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Prometheus node exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules: Define outbound traffic that is allowed. The below configuration allows all outbound traffic from the instance.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  # Tags for the security group
  tags = {
    "Name"      : "frontend_sg"                          # Name tag for the security group
    "Terraform" : "true"                                # Custom tag to indicate this SG was created with Terraform
  }
}


resource "aws_security_group" "backend_sg" {
  vpc_id     = var.vpc_id
  name        = "backend_sg"
  description = "traffic to backend server"
  # Ingress rules: Define inbound traffic that is allowed.Allow SSH traffic and HTTP traffic on port 8080 from any IP address (use with caution)
  
  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #to view frontend sever
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Prometheus node exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules: Define outbound traffic that is allowed. The below configuration allows all outbound traffic from the instance.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  # Tags for the security group
  tags = {
    "Name"      : "backend_sg"                          # Name tag for the security group
    "Terraform" : "true"                                # Custom tag to indicate this SG was created with Terraform
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "wkld5-key"
  public_key = tls_private_key.ssh_key.public_key_openssh 
}

# Saving private key as local tmp file on Jenkins server.
resource "local_file" "save_private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "/tmp/terraform_ssh_key.pem" # Temporary file
}

# Saving private key as local tmp file on Jenkins server.
resource "local_file" "save_public_key" {
  content  = tls_private_key.ssh_key.public_key_pem
  filename = "/tmp/terraform_ssh_key.pub" # Temporary file
}







