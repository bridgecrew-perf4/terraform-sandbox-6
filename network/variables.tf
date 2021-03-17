variable "cidr" {
  default = "10.0.0.0/16"
}

variable "private-subnet" {         
  default = "10.0.0.0/24"
}

variable "avail-zone" {
  default = "eu-west-1b"
}

variable "aws_default_region" {
  default = "eu-west-1"
}
