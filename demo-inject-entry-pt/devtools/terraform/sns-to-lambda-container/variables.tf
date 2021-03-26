variable "aws_default_region" {
  default = "us-east-1"
}

variable "retention_in_days" {
  default = 3
}

variable "function_name" {}
variable "repo_name" {}
variable "memory_size" {}
variable "timeout" {}
variable "sns_name" {}
variable "image_config_command" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "cidr" {}

#variable "mongo_auth_db" {}
variable "mongo_username" {}
variable "mongo_password" {}
variable "mongo_endpoint" {}

