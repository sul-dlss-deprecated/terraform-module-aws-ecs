# The cluster itself.
data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.cluster_name}"
}

data "aws_cloudwatch_log_group" "cluster" {
  name = "${var.cluster_name}"
}

data "aws_alb" "cluster_alb" {
  name = "${var.cluster_name}-alb"
}

# Default security group.
resource "aws_security_group" "cluster_alb_sg" {
  name   = "${var.cluster_name}-alb-sg"
  vpc_id = "${var.vpc_id}"
}

data "aws_alb_target_group" "cluster_alb_default_tg" {
  name = "${var.cluster_name}-alb"
}

data "aws_alb_listener" "cluster_alb_http_listener" {
  load_balancer_arn = "${aws_alb.cluster_alb.arn}"
  port              = 80
}

data "aws_alb_listener" "cluster_alb_https_listener" {
  load_balancer_arn = "${aws_alb.cluster_alb.arn}"
  port              = 443
}

# Route 53 zone for the service.
data "aws_route53_zone" "selected" {
  name         = "${var.hosted_zone_name}."
  private_zone = false
}
