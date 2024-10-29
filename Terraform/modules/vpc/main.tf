resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

# Reference the default vpc
data "aws_vpc" "default_vpc" {
  id = var.default_vpc_id
}

# Create a VPC Peering Connection between the default VPC and the Terraform-created VPC
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = data.aws_vpc.default_vpc.id  # default VPC ID
  peer_vpc_id   = aws_vpc.main.id             # Accepter VPC ID
  auto_accept   = true  # Automatically accept the peering connection
}

# Add a route to the default VPC's route table 
resource "aws_route" "default_vpc_to_vpc" {
  route_table_id         = var.default_route_table_id  # Main route table ID of the default VPC
  destination_cidr_block = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Define the routes for the public route table
resource "aws_route" "public_to_default" {
  route_table_id         = aws_route_table.public_route_table.id  
  destination_cidr_block = data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Define the routes for the first private route table
resource "aws_route" "private_to_default" {
  route_table_id = aws_route_table.private_route_table.id  # Replace with private route table ID for private subnet 1
  destination_cidr_block = data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}



resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index + 2)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}


#### GATEWAYS #### 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wl5-igw"
  }
}

resource "aws_nat_gateway" "gw-NAT" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "wl5-gw-NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}

####### ELASTIC IP ADDRESS ##########
resource "aws_eip" "nat_eip" {
  domain   = "vpc"
}

######## ROUTE TABLES & ASSOCIATIONS #######
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "wl5-public_RT"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-NAT.id
  }

  tags = {
    Name = "wl5-private_RT"
  }
}

# Public Route Table Associations
resource "aws_route_table_association" "public_association" {
  for_each       = { for index, subnet in aws_subnet.public : index => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [
    aws_subnet.public
  ]
}

# Private Route Table Associations
resource "aws_route_table_association" "private_association" {
  for_each       = { for index, subnet in aws_subnet.private : index => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.private_route_table.id

    depends_on = [
    aws_subnet.private
  ]
}


### Load Balancer Components###
# Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.main.id
  description = "security group for load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wl5-lb-security-group"
  }
}

# Load Balancer
resource "aws_lb" "public_lb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "wl5-public-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "public-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "wl5-public-target-group"
  }
}

# Listener for Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Register Instances with the Target Group
resource "aws_lb_target_group_attachment" "tg_attach" {
  count             = length(var.frontend_instance_ids)
  target_group_arn  = aws_lb_target_group.tg.arn
  target_id         = var.frontend_instance_ids[count.index]
  port              = 3000

  depends_on = [
    var.frontend_instance_ids
  ]
}