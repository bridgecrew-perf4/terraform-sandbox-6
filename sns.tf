resource "aws_vpc_endpoint" "sns" {
  vpc_id              = var.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.sns"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = [var.subnet_id]

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AccessLimitedResources",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "logs:*",
            "Condition": {"StringLike":
              {"aws:PrincipalOrgID":["${var.principal_org_id}"]}
            },
            "Resource": "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        }

    ]
}
EOF

  tags = {
    Name        = "sns-endpoint"
    Environment = "dev"
  }
}
