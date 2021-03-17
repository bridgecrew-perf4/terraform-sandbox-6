resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
      Name = "ecs-fargate-dev"
    }
} 

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private-subnet
  availability_zone       = var.avail-zone
  map_public_ip_on_launch = false
  tags = {
     Name = "private"
    }
} 

# Create the Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
} 

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "main" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
} 
