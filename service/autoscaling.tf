/*====
Auto Scaling for ECS
======*/
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "${var.service_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "75"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.service_up.arn}"]
  ok_actions    = ["${aws_appautoscaling_policy.service_down.arn}"]
}

data "aws_iam_role" "ecs_autoscale_role" {
  name = "AWSServiceRoleForApplicationAutoScaling_ECSService"
}

resource "aws_appautoscaling_target" "service" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${data.aws_iam_role.ecs_autoscale_role.arn}"
  min_capacity       = "${var.min_capacity}"
  max_capacity       = "${var.max_capacity}"
}

resource "aws_appautoscaling_policy" "service_up" {
  name                    = "${var.service_name}-${var.environment}-scale-up"
  service_namespace       = "ecs"
  resource_id             = "service/${var.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension      = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.service"]
}

resource "aws_appautoscaling_policy" "service_down" {
  name                    = "${var.service_name}-${var.environment}-scale-down"
  service_namespace       = "ecs"
  resource_id             = "service/${var.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension      = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.service"]
}
