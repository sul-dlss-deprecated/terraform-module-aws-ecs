/*====
ECS cluster
======*/
resource "aws_ecs_cluster" "cluster" {
  name = "${var.cluster_name}"
}

/*====
Cloudwatch Log Group
======*/
resource "aws_cloudwatch_log_group" "cluster" {
  name = "${var.cluster_name}"

  tags {
    Environment = "${var.environment}"
    Cluster = "${var.cluster_name}"
  }
}

/*====
ALB for cluster
======*/
resource "aws_alb" "cluster_alb" {
  name            = "${var.environment}-${var.cluster_name}-alb"
  subnets         = ["${split(",", var.public_subnets)}"]
  security_groups = ["${aws_security_group.cluster_alb_sg.id}"]

  tags {
    Name        = "${var.environment}-${var.cluster_name}-alb"
    Environment = "${var.environment}"
  }
}

/* security group for ALB */
resource "aws_security_group" "cluster_alb_sg" {
  name        = "${var.environment}-${var.cluster_name}-alb-sg"
  description = "Allow HTTP/HTTPS from Anywhere into ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment}-${var.cluster_name}-alb-sg"
  }
}

resource "random_id" "target_group" {
  byte_length = 2
}

/* default target group and listeners */
resource "aws_alb_target_group" "cluster_alb_default_tg" {
  name                  = "${var.environment}-${var.cluster_name}-alb-${random_id.target_group.hex}"
  port                  = 80
  protocol              = "HTTP"
  vpc_id                = "${var.vpc_id}"
  deregistration_delay  = 30

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "cluster_alb_http_listener" {
  load_balancer_arn = "${aws_alb.cluster_alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.cluster_alb_default_tg.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "cluster_alb_https_listener" {
  load_balancer_arn = "${aws_alb.cluster_alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate_validation.cert.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.cluster_alb_default_tg.id}"
    type             = "forward"
  }
}

/* cert for https listener */
data "aws_route53_zone" "selected" {
  name         = "${var.hosted_zone_name}."
  private_zone = false
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.cluster_name}-lb.${var.hosted_zone_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
