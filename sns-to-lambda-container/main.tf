data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "default" {
  name = var.function_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "default" {
  name        = "${var.function_name}-logging"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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

resource "aws_sns_topic_subscription" "sns" {
  topic_arn = aws_sns_topic.default.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.default.arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.default.arn
}

resource "aws_security_group" "lambda" {
  name   = "lambda"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 28000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "dev"
  }
}

resource "aws_lambda_function" "default" {
  package_type                   = "Image"
  function_name                  = var.function_name
  role                           = aws_iam_role.default.arn
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  image_uri                      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.repo_name}"
  publish                        = "true"

  image_config {
      command = [ var.image_config_command ]
  }

  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
      variables = {
        MONGO_USERNAME = var.mongo_username
        MONGO_PASSWORD = var.mongo_password
        MONGO_ENDPOINT = var.mongo_endpoint
      }
    }

}

resource "aws_cloudwatch_log_group" "default" {
  name              = "aws-lambda-${var.function_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}
