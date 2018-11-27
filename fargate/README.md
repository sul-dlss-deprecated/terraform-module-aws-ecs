# Overview

This module defines an ECS service in an already-defined cluster.  This
includes an autoscaling role for the service, a hostname and ALB configuration,
security groups, and CloudWatch alarms.

# Variables

See variables.tf for all current variables and descriptions.

# Resources

- aws_route53_record (service_name.environment.cluster_zone_name)
- aws_iam_role (task role)
- aws_ecs_task_definition
- aws_alb_target_group
- aws_alb_listener_rule (http & https)
- aws_acm_certificate (service_name.environment.cluster_zone_name)
- aws_security_group (port - all outbound)
- aws_ecs_service
- aws_cloudwatch_metric_alarm
- aws_iam_role (autoscaling role)
- aws_appautoscaling_target
- aws_appautoscaling_policy (up & down)

# Outputs

See output.tf for all current outputs.
