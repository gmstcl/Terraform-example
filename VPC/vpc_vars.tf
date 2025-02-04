variable "aws_region" {
  description = "The region in which the resources will be created"
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "The project name"
  default     = "test"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "The availability zones in which the resources will be created"
  default     = ["a", "b"]
}

variable "subnet_prefix" {
  description = "The prefix for the subnets"
  default     = 28
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  default     = [101,102]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  default     = [103,104]  
}

variable "database_subnet_cidrs" {
  description = "The CIDR blocks for the database subnets"
  default     = [105,106]
}