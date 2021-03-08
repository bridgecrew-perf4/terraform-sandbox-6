###########################################################################
# variables
###########################################################################
variable "aws_default_region" {
  default = "us-east-1"
}

variable "ecs_cluster" {}
variable "image_uri" {}

# environmental variables set for lambda function
variable "environment" {}
variable "task_definition_name" {}

data "template_file" "ecs_server" {
  template = file("./ecs_server.json.tpl")
  vars = {
    task_definition_name = var.task_definition_name
    image_uri = var.image_uri
    aws_default_region = var.aws_default_region
    command = var.command
  }
}

resource "aws_ecs_cluster" "default" {
   name  = var.ecs_cluster
}


resource "aws_ecs_task_definition" "default" {
  family                   = var.task_definition_name
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.ecs_server.rendered
}

# The Amazon Resource Name (ARN) of the task execution role that 
# the Amazon ECS container agent and the Docker daemon can assume.
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.task_definition_name}-role-execution"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# The ARN of IAM role that allows your Amazon ECS 
# container task to make calls to other AWS services.
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.task_definition_name}-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# defined custom policy
resource "aws_iam_policy" "default" {
  name        = "${var.task_definition_name}-logging"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
         "Effect": "Allow",
         "Action": [
             "s3:ListAllMyBuckets",
             "s3:GetBucketLocation"
         ],
         "Resource": "*"
     },
     {
         "Effect": "Allow",
         "Action": "s3:*",
         "Resource": [
             "arn:aws:s3:::${var.CHANGETHIS}"
         ]
     },
     {
       "Action": [
         "autoscaling:Describe*",
         "cloudwatch:*",
         "logs:*",
         "sns:*"
       ],
       "Effect": "Allow",
       "Resource": "*"
     },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:AttachNetworkInterface"
        ],
        "Resource": [
            "*"
        ]
    }
  ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/fargate/${var.task_definition_name}"
  retention_in_days = 1
}
