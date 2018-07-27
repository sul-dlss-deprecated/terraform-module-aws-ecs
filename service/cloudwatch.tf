# This mimics what we do to scale up a CPU high alert, but is over a longer
# period and meant to just alert.  Essentially if the alert isn't going away
# even after scaling up new services, we want someone to look at it.
resource "aws_cloudwatch_metric_alarm" "service_cpu_high_alert" {
  alarm_name          = "${var.service_name}-${var.environment}-cpu-high-alert"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "10"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "75"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_actions = ["${var.cloudwatch_alerts_arn}"]
  ok_actions    = ["${var.cloudwatch_alerts_arn}"]
}
