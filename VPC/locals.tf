locals {
  availability_cidr_blocks = [
    for i in range(0, 255) : cidrsubnet(var.vpc_cidr, 8, i)
  ]

  public_subnet_cidrs = [
    for i in range(0, length(var.public_subnet_cidrs)) : cidrsubnet(local.availability_cidr_blocks[var.public_subnet_cidrs[i]], 0, 0)
  ]

  private_subnet_cidrs = [
    for i in range(0, length(var.private_subnet_cidrs)) : cidrsubnet(local.availability_cidr_blocks[var.private_subnet_cidrs[i]], 0, 0)
  ]

  database_subnet_cidrs = [
    for i in range(0, length(var.database_subnet_cidrs)) : cidrsubnet(local.availability_cidr_blocks[var.database_subnet_cidrs[i]], 0, 0)
  ]

  availability_zones = [for az in var.availability_zones : "${var.aws_region}${az}"]

  public_subnet_names = [for i in range(0, length(var.public_subnet_cidrs)) : "${var.project_name}-public-subnet-${var.availability_zones[i]}"]
  private_subnet_names = [for i in range(0, length(var.private_subnet_cidrs)) : "${var.project_name}-private-subnet-${var.availability_zones[i]}"]
  database_subnet_names = [for i in range(0, length(var.database_subnet_cidrs)) : "${var.project_name}-database-subnet-${var.availability_zones[i]}"]
}