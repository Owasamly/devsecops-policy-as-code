resource "aws_vpc" "policy_lab" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, { Name = "policy-as-code-lab" })
}

resource "aws_security_group" "application" {
  name        = "policy-as-code-application"
  description = "Restricted application ingress for the policy lab"
  vpc_id      = aws_vpc.policy_lab.id

  ingress {
    description = "HTTPS from the trusted management network"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.management_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "policy-as-code-application" })
}
