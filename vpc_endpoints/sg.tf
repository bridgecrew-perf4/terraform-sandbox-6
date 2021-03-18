resource "aws_security_group" "vpce" {
  name   = "vpce"
  vpc_id = var.vpc_id

  ingress {
    to_port     = 443
    from_port   = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    to_port     = 443
    from_port   = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "dev"
  }
}
