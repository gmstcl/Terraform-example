resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name   = "test.pem"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "bastion_local" {
  filename = "${pathexpand("~\\Downloads\\test.pem")}"
  content  = tls_private_key.key.private_key_pem
}

resource "aws_security_group" "ec2_secgroup" {
  name   = "${var.project_name}-bastion-sg"
  vpc_id = module.vpc.vpc_id
  description = "Allow inbound traffic from port 443, to the VPN"
 
  ingress {
   protocol         = "tcp"
   from_port        = 22
   to_port          = 22
   cidr_blocks      = ["${chomp(data.http.myip.response_body)}/32"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-bastion-role"

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
    Name        = "${var.project_name}-bastion-role"
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

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type          = "t2.micro"
  key_name               = aws_key_pair.keypair.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.ec2_secgroup.id]
  subnet_id              = element(module.vpc.public_subnets, 0)
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y httpd
              systemctl start httpd
              EOF
}