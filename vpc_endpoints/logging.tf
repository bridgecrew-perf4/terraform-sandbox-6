resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = [var.subnet_id]

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "GrantStarPort",
            "Effect": "Allow",
            "Action": [
                       "logs:CreateLogDelivery",
                       "logs:CreateLogGroup",
                       "logs:CreateLogStream",
                       "logs:DescribeLogGroups",
                       "logs:DescribeLogStreams",
                       "logs:GetLogDelivery",
                       "logs:GetLogRecord",
                       "logs:PutDestination",
                       "logs:PutLogEvents",
                       "logs:UpdateLogDelivery"
                       ],
            "Principal": {
                "AWS": "*"
            },
            "Resource": "*"
        },
        {
            "Sid": "GrantAccessToOrg",
            "Effect": "Allow",
            "Action": "logs:*",
            "Principal": {
                "AWS": "*"
            },
            "Condition": {"StringLike":
              {"aws:PrincipalOrgID":["${var.principal_org_id}"]}
            },
            "Resource": "*"
        }
    ]
}
EOF

  tags = {
    Name        = "logs-endpoint"
    Environment = "dev"
  }
}
