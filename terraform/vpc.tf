# Main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#--------Subnets---------

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true # Automatically assign public IP to any EC2 in the subnet

  tags = {
    Name = "${var.project_name}-${var.az1}-public"
  }
}

# Private Subnet 1
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.az1

  tags = {
    Name = "${var.project_name}-${var.az1}-private"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.az2

  tags = {
    Name = "${var.project_name}-${var.az2}-private"
  }
}

# -------Public Route Table---------

# Public Route Table to determine how network traffic flows through the Internet Gateway
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${var.project_name}-route-table-public"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

# -------Private Route Table---------

# Set rules for traffic flow in the private subnets
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-route-table-private"
  }
}

# Associate the public route table with the private subnet 'a'
resource "aws_route_table_association" "private_subnet_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route.id
}

# Associate the public route table with the private subnet 'b'
resource "aws_route_table_association" "private_subnet_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route.id
}