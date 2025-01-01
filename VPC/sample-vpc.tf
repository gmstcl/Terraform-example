# Variables
variable "aws_region" {
  default = "ap-northeast-2"
}

variable "project_name" {
  default = "MyProject" 
}

variable "cidr" {
  default = "10.0.0.0/16" 
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-VPC"
  }
}

# Subnet Definitions
locals {
  azs          = ["a", "b"]                      
  subnet_cidrs = {                                
    public  = ["10.0.1.0/24", "10.0.2.0/24"]
    private = ["10.0.3.0/24", "10.0.4.0/24"]
    db      = ["10.0.5.0/24", "10.0.6.0/24"]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-IGW"
  }
}

# NAT Gateways
resource "aws_eip" "nat" {
  count = length(local.azs)
}

resource "aws_nat_gateway" "main" {
  count         = length(local.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.project_name}-NAT-${local.azs[count.index]}"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidrs.public[count.index]
  availability_zone       = "${var.aws_region}${local.azs[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-Public-${local.azs[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidrs.private[count.index]
  availability_zone = "${var.aws_region}${local.azs[count.index]}"
  tags = {
    Name = "${var.project_name}-Private-${local.azs[count.index]}"
  }
}

resource "aws_subnet" "db" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidrs.db[count.index]
  availability_zone = "${var.aws_region}${local.azs[count.index]}"
  tags = {
    Name = "${var.project_name}-DB-${local.azs[count.index]}"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-Public-RT"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(local.azs)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-Private-RT-${local.azs[count.index]}"
  }
}

resource "aws_route" "private" {
  count                 = length(local.azs)
  route_table_id        = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Output
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "db_subnets" {
  value = aws_subnet.db[*].id
}
