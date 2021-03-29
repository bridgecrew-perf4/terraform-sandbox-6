variable "ami_search" {
  type    = list
}

variable "owners" {
  default     = ["amazon"]
}

variable "server_count" {
  default     = 1
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "security_group_ids" {
  type        = string
  default     = "sg-05462531ad868d1d3"
}

variable "subnet_id" {
  type        = string
  default     = "subnet-050ae29e35ba462d1"
}

variable "server_name_base" {
  type        = string
  default     = "mongodb"
}

variable "volume_size" {
  default     = 80
}

variable "key_name" {
  default     = "mongodb"
}
