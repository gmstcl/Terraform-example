module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "demo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false 
  one_nat_gateway_per_az = true  

  tags = {
    Terraform    = "true"
    Environment  = "dev"
  }
}

resource "aws_ec2_tag" "private_subnet_a_tag" {
  resource_id    = module.vpc.private_subnets[0]
  key            = "Name"
  value          = "demo-pvt-sn-1a"
}

resource "aws_ec2_tag" "private_subnet_b_tag" {
  resource_id    = module.vpc.private_subnets[1]
  key            = "Name"
  value          = "demo-pvt-sn-1b"
}

resource "aws_ec2_tag" "public_subnet_a_tag" {
  resource_id    = module.vpc.public_subnets[0]
  key            = "Name"
  value          = "demo-pub-sn-1a"
}

resource "aws_ec2_tag" "public_subnet_b_tag" {
  resource_id    = module.vpc.public_subnets[1]
  key            = "Name"
  value          = "demo-pub-sn-1b"
}