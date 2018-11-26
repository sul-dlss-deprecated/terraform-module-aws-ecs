variable "cluster_name" {
  description = "Cluster name to be used in resource names"
}

variable "environment" {
  description = "Environment for the resources, used in naming and tags"
}

variable "vpc_id" {
  description = "VPC ID to place the resources within"
}

variable "open_ports" {
  description = "Ports we open access to in the default security group"
  default     = ["80", "443"]
}

variable "public_subnets" {
  description = "Subnets to use in creating the application load balancer"
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name to use for creating an ALB cert"
}

variable "certificate_name" {
  description = "Hostname for the certificate to use for validation"
  default     = ""
}

variable "alb_cidr" {
  type    = "list"
  default = ["0.0.0.0/0"]
}
