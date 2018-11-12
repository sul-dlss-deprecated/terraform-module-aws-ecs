# Overview

This module defines an ECS execution role and deploy user, with permissions
necessary to update and run services and tasks.

# Variables

See `variables.tf` for all current variables and descriptions.

### Resources
- aws_iam_role (execution role)
- aws_iam_user (${environment}-ecs-deployer)
  - aws_iam_access_key
    - ecs:RegisterTaskDefinition
    - ecs:RunTask
    - ecs:ListClusters
    - ecs:ListTaskDefinitions
    - ecs:UpdateService
    - ec2:DescribeVpcs
    - ec2:DescribeSubnets
    - ec2:DescribeSecurityGroups
    - ecs:DescribeTasks
    - iam:GetRole
    - iam:PassRole

# Outputs

See `output.tf` for all current outputs.
