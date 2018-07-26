# Overview

This module defines an ECS cluster for specific services to be placed in, along
with an application load-balancer with certificate.  It also creates a
cloudwatch log group to later place further log topics into.

# Variables

See variables.tf for all current variables and descriptions.

# Resources
- aws_ecs_cluster
- aws_cloudwatch_log_group
- aws_alb (public)
  - aws_security_group (80 & 443 world - all outbound)
  - aws_alb_target_group (no targets)
  - aws_alb_listener (http & https)
  - aws_acm_certificate (cluster_name-lb.hosted_zone_name)

# Outputs

See output.tf for all current outputs.

# Known problems

When creating a cluster, terraform sometime returns the following error. However, rerunning
terraform usually resolves the problem. There probably needs to be a `depends_on` set on
some resource.
```console
Error: Error applying plan:

1 error(s) occurred:

* module.infra_cluster.output.alb_http_listener_arn: Resource 'aws_alb_listener.cluster_alb_http_listener' does not have attribute 'arn' for variable 'aws_alb_listener.cluster_alb_http_listener.arn'
```
