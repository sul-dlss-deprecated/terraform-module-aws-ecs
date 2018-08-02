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

# Get the data for the given HTTP and HTTPS listeners.
data "aws_lb" "service" {
  name = "${var.cluster_name}-alb"
}

resource "aws_cloudwatch_metric_alarm" "elb_response" {
  alarm_name          = "${var.service_name}-${var.environment}-elb-response-slow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "60"
  treat_missing_data  = "notBreaching"

  dimensions {
    LoadBalancer = "${data.aws_lb.service.arn_suffix}"
    TargetGroup  = "${aws_alb_target_group.service.arn_suffix}"
  }

  alarm_actions = ["${var.cloudwatch_alerts_arn}"]
  ok_actions    = ["${var.cloudwatch_alerts_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "elb_health_hosts" {
  alarm_name          = "${var.service_name}-${var.environment}-elb-health-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"

  dimensions {
    LoadBalancer = "${data.aws_lb.service.arn_suffix}"
    TargetGroup  = "${aws_alb_target_group.service.arn_suffix}"
  }

  alarm_actions = ["${var.cloudwatch_alerts_arn}"]
  ok_actions    = ["${var.cloudwatch_alerts_arn}"]
}
