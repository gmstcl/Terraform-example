module "endpoints" {
    source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

    vpc_id             = module.vpc.vpc_id
    security_group_ids = [aws_default_security_group.default.id]  

    endpoints = {
        s3 = {
            service             = "s3"
            //private_dns_enabled = true
            security_group_ids  = [aws_default_security_group.default.id]  
            subnet_ids          = module.vpc.private_subnets
            tags                = { Name = "${var.project_name}-s3-ep" }
        },
        ecr_api = {
            service             = "ecr.api"
            private_dns_enabled = true
            security_group_ids  = [aws_default_security_group.default.id]  
            subnet_ids          = module.vpc.private_subnets  
            tags                = { Name = "${var.project_name}-ecr.api-ep" }
        },
        ecr_dkr = {
            service             = "ecr.dkr"
            private_dns_enabled = true
            security_group_ids  = [aws_default_security_group.default.id]  
            subnet_ids          = module.vpc.private_subnets  
            tags                = { Name = "${var.project_name}-ecr.dkr-ep" }
        },
    }

    tags = {
        Owner       = "root"
        Environment = "dev"
    }
}
