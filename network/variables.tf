variable "main_cidr" {
  default = "10.0.0.0/16"
}

variable "private-subnet-01" {         
  default = "10.0.1.0/24"
}

variable "private-subnet-02" {         
  default = "10.0.2.0/24"
}

variable "avail-zone-02" {
  default = "eu-west-1b"
}

variable "avail-zone-01" {
  default = "eu-west-1a"
}

variable "aws_default_region" {
  default = "eu-west-1"
}
