data "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-ecs-task-execution-role"
}
