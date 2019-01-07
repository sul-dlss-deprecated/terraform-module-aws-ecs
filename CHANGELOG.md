# v17

* Fixed errors with v16.

# v16

* Add `project` tag to the main variable sets, to set Terraform tags.
* cluster: Add `project` tag to the variables and set Terraform tags.
* fargate: Add `project` tag to the variables and set Terraform tags.

# v15

* fargate: Add override for http and https listeners, for the case of
  shibboleth where we want to use an ALB other than the cluster default.  This
  is just set by overriding default http_listener and https_listener in
  variables, and so won't change anything on upgrade.

# v14

* fargate: Separate out security group rules from security group, to allow
  editing them outside of the module.  While this won't change the end result
  of anything calling the module, you might need to manually delete the
  existing versions of the security group rules from the security group via the
  AWS console or CLI.

# v13

* fargate: Change the name of the target group to remove the random string as
  unneeded, and to make it easier to tell cluster and ECS target groups apart.

# v12

* service: Rename to fargate in prep for creating a separate EC2 ECS directory.
* service: Update to look up most values via data blocks rather than passing
  along so many values.
    Removed:
      service_host (already replaced by service_fullhost)
      cluster_id
      cluster_zone_id
      cluster_alb_zone_id
      cluster_alb_http_listener_arn
      cluster_alb_https_listener_arn
      cluster_alb_security_group_id

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
