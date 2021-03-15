resource "aws_security_group" "vpce" {
  name   = "vpce"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }
  tags = {
    Environment = "dev"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids   = [var.route_table_id]

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:PutObjectAcl",
                "s3:PutObject",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:Delete*"
            ],
            "Resource": [
                "arn:aws:s3:::prod-${data.aws_region.current.name}-starport-layer-bucket",
                "arn:aws:s3:::prod-${data.aws_region.current.name}-starport-layer-bucket/*"
            ]
        }
    ]
  }
  EOF
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecs-agent"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecs-telemetry"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloudwatch-logs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.subnet_id]
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

################################################################################################
#"arn:aws:s3:::govukverify-self-service-integration-config-metadata",
#"arn:aws:s3:::govukverify-self-service-integration-config-metadata/*"
#"arn:aws:s3:::gds-${var.deployment}-ssm-session-logs-store",
#"arn:aws:s3:::gds-${var.deployment}-ssm-session-logs-store/*",
#"arn:aws:s3:::govukverify-self-service-${var.deployment}-config-metadata",
#"arn:aws:s3:::govukverify-self-service-${var.deployment}-config-metadata/*",
#resource "aws_security_group" "cloudwatch_vpc_endpoint" {
#  name        = "${var.deployment}-cloudwatch-vpc-endpoint"
#  description = "${var.deployment}-cloudwatch-vpc-endpoint"
#  vpc_id = var.vpc_id
#}
#
#resource "aws_vpc_endpoint" "cloudwatch" {
#  vpc_id            = var.vpc_id
#  service_name      = "com.amazonaws.${data.aws_region.current.name}.monitoring"
#  vpc_endpoint_type = "Interface"
#  subnet_ids = [var.subnet_id]
#  security_group_ids = [aws_security_group.vpce.id]
#  private_dns_enabled = true
#}
#
#resource "aws_security_group" "container_vpc_endpoint" {
#  name        = "${var.deployment}-container-vpc-endpoint"
#  description = "${var.deployment}-container-vpc-endpoint"
#  vpc_id = var.vpc_id
#}
################################################################################################
