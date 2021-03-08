[
  {
    "essential": true,
    "memory": 512,
    "name": "${task_definition_name}",
    "cpu": 2,
    "image": "${image_uri}",
    "command": ["${command}"],
    "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group" : "/aws/fargate/${task_definition_name}",
                    "awslogs-region" : "${aws_default_region}",
                    "awslogs-stream-prefix": "ecs"
                }
            },
    "environment": [
            {
                "name": "environment",
                "value": "${environment}"
            }
        ]
  }
]
