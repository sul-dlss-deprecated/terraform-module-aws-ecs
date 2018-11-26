# v11

* service: set the health check protocol to the same protocol as the
  service.

# v10

* service: Set default alb redirect rule.

# v9

* Add a data version of the main ecs module, to allow sub-modules to include
  values for the main ecs setup.

# v8

* Make alb cidr block a variable.

# v7

* Fix service/ not actually using the protocol variable.

# v6

* Change how cluster ALB security group is set.  It now uses a series of
  aws_security_group_rule statements rather than placing everything in the
  aws_security_group directly.  This lets someone add more rules outside of the
  module if needed.

# v4

* Rename LB default service name to remove environment, to handle 32 character
  limit being hit.

# v3

* Add CloudWatch metrics for ALB host count low and high response time.

# v2

* Added CloudWatch alerting if high CPU for over 10m
* Added variable `cloudwatch_alerts_arn` for SNS topic for alerting

# v1

* First full release
