resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "bastion_local" {
  filename = "${pathexpand("~\\Downloads\\${var.key_name}")}"
  content  = tls_private_key.key.private_key_pem
}

resource "aws_security_group" "ec2_secgroup" {
  name   = "${var.project_name}-${var.security_groups_ec2_name}"
  vpc_id = module.vpc.vpc_id
  description = "Allow inbound traffic from port 443, to the VPN"
 
  ingress {
   protocol         = var.ec2_ingress.protocol
   from_port        = var.ec2_ingress.from_port
   to_port          = var.ec2_ingress.to_port
   cidr_blocks      = ["${chomp(data.http.myip.response_body)}/32"]
  }
 
  egress {
   protocol         = var.ec2_egress.protocol
   from_port        = var.ec2_egress.from_port
   to_port          = var.ec2_egress.to_port
   cidr_blocks      = var.ec2_egress.cidr_blocks
  }

  tags = {
    Name = "${var.project_name}-${var.security_groups_ec2_name}"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.aws_iam_role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.aws_iam_role_name}"
    Environment = "dev"
  }
}

resource "aws_iam_policy_attachment" "ec2_role_policy_attachment" {
  name       = "ec2-admin-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  roles      = [aws_iam_role.ec2_role.name]
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.project_name}-ec2-instance-profile"
    Environment = "dev"
  }
}

data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.ec2_name}"

  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.keypair.key_name
  monitoring             = var.monitoring
  vpc_security_group_ids = [aws_security_group.ec2_secgroup.id]
  subnet_id              = element(module.vpc.public_subnets, 0)
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  metadata_options = {
    "http_endpoint": "enabled",
    "http_put_response_hop_limit": 2,
    "http_token": "required"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = <<-EOF
              #!/bin/bash
              curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.4/2025-01-10/bin/darwin/amd64/kubectl.sha256
              chmod +x kubectl 
              mv kubectl /usr/bin
              echo 'alias k=kubectl' >>~/.bashrc
              source ~/.bashrc
              EOF
}