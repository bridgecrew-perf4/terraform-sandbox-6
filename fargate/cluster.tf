resource "aws_security_group" "ecs_task" {
  name   = "ecs"
  vpc_id = var.vpc_id
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [var.prefix_list_id]
  }

  tags = {
    Environment = "dev"
  }

}

resource "aws_ecs_cluster" "main" {
  name   = "cluster"
}

resource "aws_ecs_service" "main" {
  name            = "service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = "1"
  platform_version = "1.3.0"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_task.id]
    subnets         = [var.subnet_id]
  }
}

locals {
  container_defintion = [{
    cpu         = 256
    image       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.app_image}"
    memory      = 1024
    name        = "app"
    networkMode = "awsvpc"
    logConfiguration = {
      logdriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/fargate/${var.task_definition_name}"
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "stdout"
      }
    }
  }]
}

resource "aws_ecs_task_definition" "default" {
  family                   = "app"
  network_mode             = "awsvpc"
  cpu                      = local.container_defintion.0.cpu
  memory                   = local.container_defintion.0.memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode(local.container_defintion)
  execution_role_arn       = aws_iam_role.fargate_execution.arn
  task_role_arn            = aws_iam_role.fargate_task.arn
  tags = {
    Name        = "app"
    Environment = "dev"
  }
}

resource "aws_iam_policy" "fargate_execution" {
  name = "${var.task_definition_name}-role-execution"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [  
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability"
        ],
        "Resource": "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.app_image}"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetAuthorizationToken"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "fargate_task" {
  name = "${var.task_definition_name}-role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [  
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

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

data "aws_iam_policy_document" "fargate-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}
 
resource "aws_iam_role" "fargate_execution" {
  name               = "fargate_execution_role"
  assume_role_policy = data.aws_iam_policy_document.fargate-role-policy.json
}

resource "aws_iam_role" "fargate_task" {
  name               = "fargate_task_role"
  assume_role_policy = data.aws_iam_policy_document.fargate-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.fargate_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = aws_iam_role.fargate_task.name
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/fargate/${var.task_definition_name}"
  retention_in_days = 1
}
