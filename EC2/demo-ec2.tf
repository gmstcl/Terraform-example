resource "aws_security_group" "demo_security_group" {
  name        = "demo-security-group"
  description = "Allow SSH traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "demo-security-group"
    Environment = "dev"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "demo-ec2-administrator-role"

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
    Name        = "demo-ec2-administrator-role"
    Environment = "dev"
  }
}

resource "aws_iam_policy_attachment" "ec2_role_policy_attachment" {
  name       = "ec2-admin-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  roles      = [aws_iam_role.ec2_role.name]
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "ec2-instance-profile"
    Environment = "dev"
  }
}

resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo_keypair" {
  key_name   = "demo-keypair.pem"
  public_key = tls_private_key.demo_key.public_key_openssh
}

resource "local_file" "bastion_local" {
  filename        = "demo-keypair.pem"
  content         = tls_private_key.demo_key.private_key_pem
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name                   = "demo-instance"
  instance_type          = "t3.small"
  key_name               = aws_key_pair.demo_keypair.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.demo_security_group.id]
  subnet_id              = module.vpc.public_subnets[0]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}