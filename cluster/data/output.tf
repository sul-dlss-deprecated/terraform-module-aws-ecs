output "name" {
  value = "${data.aws_ecs_cluster.cluster.name}"
}

output "id" {
  value = "${data.aws_ecs_cluster.cluster.id}"
}

output "arn" {
  value = "${data.aws_ecs_cluster.cluster.arn}"
}

output "zone_id" {
  value = "${data.aws_route53_zone.selected.zone_id}"
}

output "zone_name" {
  value = "${data.aws_route53_zone.selected.name}"
}

output "alb_security_group_id" {
  value = "${data.aws_security_group.cluster_alb_sg.id}"
}

output "alb_dns_name" {
  value = "${data.aws_alb.cluster_alb.dns_name}"
}

output "alb_zone_id" {
  value = "${data.aws_alb.cluster_alb.zone_id}"
}

output "alb_default_target_group_arn" {
  value = "${data.aws_alb_target_group.cluster_alb_default_tg.arn}"
}

output "alb_http_listener_arn" {
  value = "${data.aws_alb_listener.cluster_alb_http_listener.arn}"
}

output "alb_https_listener_arn" {
  value = "${data.aws_alb_listener.cluster_alb_https_listener.arn}"
}

output "cloudwatch_log_group_name" {
  value = "${data.aws_cloudwatch_log_group.cluster.name}"
}
