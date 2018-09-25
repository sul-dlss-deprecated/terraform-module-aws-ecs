output "execution_role_arn" {
  value = "${data.aws_iam_role.ecs_execution_role.arn}"
}
