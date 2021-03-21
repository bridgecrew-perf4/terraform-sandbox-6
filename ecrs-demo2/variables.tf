variable "aws_default_region" {
  default = "us-east-1"
}

variable "ecr-name" {
  type        = string
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
}

variable "image_scanning_configuration" {
  type        = map
  description = "Configuration block that defines image scanning configuration for the repository. By default, image scanning must be manually triggered. See the ECR User Guide for more information about image scanning."
  default     = {}
}

variable "tags" {
  type        = map
  description = "A map of tags to assign to the resource"
  default     = {}
}

variable "scan_on_push" {
  type        = bool
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)"
  default     = "true"
}

variable "lifecycle_policy" {
  default = <<EOF

{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 1 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["test","dev"],
                "countNumber": 1,
                "countType": "imageCountMoreThan"
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire images older than 1 minute",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
