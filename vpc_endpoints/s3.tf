resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_id]
 
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "GrantStarPort",
            "Effect": "Allow",
            "Action": "s3:*",
            "Principal": {
                "AWS": "*"
            },
            "Resource": [
                "arn:aws:s3:::prod-${data.aws_region.current.name}-starport-layer-bucket/*${data.aws_caller_identity.current.account_id}*/*"
            ]
        }
    ]
}
EOF

  tags = {
    Name        = "s3-endpoint"
    Environment = "dev"
  }
}
