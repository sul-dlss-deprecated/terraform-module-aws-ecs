/*====
ECS execution role
======*/
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-ecs-task-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags {
    terraform = "true"
    project   = "${var.project}"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_cloudwatch" {
  role       = "${aws_iam_role.ecs_execution_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_user" "deployer" {
  name = "${var.environment}-ecs-deployer"

  tags {
    terraform = "true"
    project   = "${var.project}"
  }
}

resource "aws_iam_access_key" "deployer" {
  user = "${aws_iam_user.deployer.name}"
}

resource "aws_iam_user_policy" "deployer" {
  name = "${var.environment}-ecs-deployer"
  user = "${aws_iam_user.deployer.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:RegisterTaskDefinition",
                "ecs:RunTask",
                "ecs:ListClusters",
                "ecs:ListTaskDefinitions",
                "ecs:UpdateService",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ecs:DescribeTasks",
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
