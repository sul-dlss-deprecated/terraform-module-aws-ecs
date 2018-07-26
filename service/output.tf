output "task_role_arn" {
  value = "${aws_iam_role.ecs_task_role.arn}"
}

output "task_role_name" {
  value = "${aws_iam_role.ecs_task_role.name}"
}

output "security_group_id" {
  value = "${aws_security_group.ecs_service.id}"
}

output "task_definition_arn" {
  value = "${aws_ecs_task_definition.service.arn}"
}
