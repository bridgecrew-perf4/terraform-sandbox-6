resource "aws_vpc_endpoint" "ecr_api" {
 
  vpc_id            = var.vpc_id
  private_dns_enabled = true
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = [var.subnet_id]
 
  policy = <<EOF
{
    "Statement": [
        {
            "Sid": "GrantReadOnlyAccessToOrg",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Condition": {"StringLike":
              {"aws:PrincipalOrgID":["${var.principal_org_id}"]}
            },
            "Resource": [ "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
                          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository",
                          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*",
                          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.repo_name}",
                          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.repo_name}/*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
  tags = {
    Name        = "ecr-api"
    Environment = "dev"
  }
 
}

