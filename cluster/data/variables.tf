variable "cluster_name" {
  description = "Cluster name to be used in resource names"
}

variable "vpc_id" {
  description = "VPC ID to place the resources within"
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name to use for creating an ALB cert"
}
