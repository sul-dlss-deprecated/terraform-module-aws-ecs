#######################################################################
# Service name
#######################################################################

variable "service_name" {
  description = "Name of the service used in resource names along with environment (should only be alphanumeric characters or hyphens)"
}

variable "environment" {
  description = "Environment name used in resource names along with service_name"
}

variable "service_fullhost" {
  description = "Hostname for the ALB (ie: 'consul.stanford.edu')"
  default     = ""
}

#######################################################################
# Service settings
#######################################################################

variable "port" {
  description = "Port for the ALB to connect to on ECS instance"
}

variable "protocol" {
  description = "Protocol for the ALB to use to connect to the ECS instance (HTTP/HTTPS)"
}

variable "health_check_url" {
  description = "URL to hit on the ECS instance for health checks"
}

variable "cpu" {
  description = "CPU units used by this task"
}

variable "memory" {
  description = "Amount (in MB) used by the task"
}

variable "min_capacity" {
  description = "Minimum number of tasks to run"
}

variable "max_capacity" {
  description = "Maximum number of tasks to run"
}

variable "container_definition" {
  description = "JSON container definition for the task(s) to run"
}

variable "service_type" {
  default     = "FARGATE"
  description = "TYPE and COMPATIBILITY for container service, default [FARGATE]."
}

#######################################################################
# Cluster and VPC settings
#######################################################################

variable "cluster_name" {
  description = "Cluster name to create in"
}

variable "cluster_zone_name" {
  description = "AWS Route53 zone name for the cluster"
}

variable "cluster_alb_dns_name" {
  description = "Hostname for the ALB connection"
}

variable "cloudwatch_alerts_arn" {
  description = "SNS topic for cloudwatch alerts"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnets" {
  description = "Private subnets that the ECS service is placed into"
}

variable "execution_role_arn" {
  description = "Execution role assigned to the ECS task"
}
