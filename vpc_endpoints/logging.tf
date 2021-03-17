resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = [var.subnet_id]

  tags = {
    Name        = "logs-endpoint"
    Environment = "dev"
  }
}
