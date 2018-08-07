# Overview

This module defines an ECS cluster for specific services to be placed in, along
with an application load-balancer with certificate.  It also creates a
cloudwatch log group to later place further log topics into.

The ALB gets a security group with ports open from the world to given ports on
the ALB.  If none are given, then we assume that the HTTP and HTTPS ports
should be opened.  The security group is set with aws_security_group_rule, so
further rules can be added outside of the module if needed.

One thing to keep in mind is that this only sets up the security group used for
external access to the application load-balancer.  Any rules between resources
in the cluster need to be set up separately.

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

## Port limitations

This creates the aws_alb_target_group and aws_alb_listener assuming you always
want HTTP and HTTPS, and creates none for other ports.  Using count to iterate
through these to work off of the ports given automatically is hard because:

1. aws_alb_target_group doesn't do a 1:1 mapping, as it will have only one for
both http and https.
2. aws_alb_listener has different settings for http and https, so can't be set
up with a count.

We might want to make this more intelligent somehow in the long term, but in
the short everything we have as a cluster does need an HTTP target
group/listener.

## Creation error

When creating a cluster, terraform sometime returns the following error. However, rerunning
terraform usually resolves the problem. There probably needs to be a `depends_on` set on
some resource.
```console
Error: Error applying plan:

1 error(s) occurred:

* module.infra_cluster.output.alb_http_listener_arn: Resource 'aws_alb_listener.cluster_alb_http_listener' does not have attribute 'arn' for variable 'aws_alb_listener.cluster_alb_http_listener.arn'
```
