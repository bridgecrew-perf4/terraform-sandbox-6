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
