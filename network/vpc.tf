resource "aws_vpc" "main" {
  cidr_block           = var.main_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
      Name = "ecs-fargate-dev"
    }
} 

resource "aws_subnet" "private-02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private-subnet-02
  availability_zone       = var.avail-zone-02
  map_public_ip_on_launch = false

  tags = {
     Name = "private-02"
    }

} 

resource "aws_subnet" "private-01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private-subnet-01
  availability_zone       = var.avail-zone-01
  map_public_ip_on_launch = false

  tags = {
     Name = "private-01"
    }

} 

# Create the Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
} 

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "main-01" {
    subnet_id      = aws_subnet.private-01.id
    route_table_id = aws_route_table.private.id
} 

resource "aws_route_table_association" "main-02" {
    subnet_id      = aws_subnet.private-02.id
    route_table_id = aws_route_table.private.id
} 
