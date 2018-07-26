#######################################################################
# Service name
#######################################################################

variable "service_name" {
  description = "Name of the service used in resources along with environment"
}

variable "environment" {
  description = "Environment name used in resources along with service_name"
}

variable "service_host" {
  description = "Shorthost for the ALB hostname (ie: 'consul' for consul.sul.stanford.edu)"
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

#######################################################################
# Cluster and VPC settings
#######################################################################

variable "cluster_id" {
  description = "Cluster ID to create in"
}

variable "cluster_name" {
  description = "Cluster name to create in"
}

variable "cluster_zone_id" {
  description = "AWS Route53 zone_id for the cluster"
}

variable "cluster_zone_name" {
  description = "AWS Route53 zone name for the cluster"
}

variable "cluster_alb_dns_name" {
  description = "Hostname for the ALB connection"
}

variable "cluster_alb_zone_id" {
  description = "AWS Route53 zone_id for the ALB (should actually be same as cluster_zone_id)"
}

variable "cluster_alb_http_listener_arn" {
  description = "ALB listener for port 80"
}

variable "cluster_alb_https_listener_arn" {
  description = "ALB listener for port 443"
}

variable "cluster_alb_security_group_id" {
  description = "Security group into the ALB"
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
