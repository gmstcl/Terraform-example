resource "aws_acm_certificate" "server_vpn_cert" {
  certificate_body  = file("${var.server_cert}")
  private_key       = file("${var.server_private_key}")
  certificate_chain = file("${var.ca_cert}")
}

resource "aws_acm_certificate" "client_vpn_cert" {
  certificate_body  = file("${var.client_cert}")
  private_key       = file("${var.client_private_key}")
  certificate_chain = file("${var.ca_cert}")
}

resource "aws_security_group" "vpn_secgroup" {
  name   = "client-vpn-sg"
  vpc_id = module.vpc.vpc_id
  description = "Allow inbound traffic from port 443, to the VPN"
 
  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-client-sg-vpn"
  }
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "${var.project_name}-client vpn"
  server_certificate_arn = aws_acm_certificate.server_vpn_cert.arn
  client_cidr_block      = "10.100.0.0/22"
  dns_servers            = ["10.0.0.2"]
  vpc_id                 = module.vpc.vpc_id
  
  security_group_ids     = [aws_security_group.vpn_secgroup.id]
  split_tunnel           = true

  # Client authentication
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_vpn_cert.arn
  }

  connection_log_options {
    enabled = false
   }

    tags = {
      Name = "${var.project_name}-client-vpn"
    }

  depends_on = [
    aws_acm_certificate.server_vpn_cert,
    aws_acm_certificate.client_vpn_cert
  ]
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_private" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = tolist(module.vpc.private_subnets)[0]
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_public" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = tolist(module.vpc.public_subnets)[1]
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}