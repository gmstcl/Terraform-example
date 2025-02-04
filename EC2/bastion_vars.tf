variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "apne2.pem"
}

variable "ec2_name" {
    description = "Name of the EC2 instance"
    type        = string
    default     = "bastion" 
}

variable "security_groups_ec2_name" {
  description = "Name of the security group"
  type        = string
  default     = "bastion-sg"   
}

variable "aws_iam_role_name" {
  description = "EC2 Instance Bastion Role Name"
  type        = string
  default     = "bastion-role"
}

variable "ec2_ingress" {
  description = "MyIP inbound traffic from port 22"
  default     = {
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
  }
}

variable "ec2_egress" {
 description  = "MyIP OutBound traffic from port ALL"
  default     = {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}