# Some logic to generate the service host using the name and cluster zone if
# no host is given.
locals {
  default_service_host = "${var.service_name}.${var.cluster_zone_name}"
  service_host         = "${var.service_fullhost != "" ? var.service_fullhost : local.default_service_host}"

  http_listener        = "${var.http_listener != "" ? var.http_listener : data.aws_alb_listener.cluster_alb_http_listener.arn}"
  https_listener       = "${var.https_listener != "" ? var.https_listener : data.aws_alb_listener.cluster_alb_https_listener.arn}"
}

# Create a route53 record for the service to use.
resource "aws_route53_record" "service" {
  zone_id = "${data.aws_route53_zone.selected.id}"
  name    = "${local.service_host}"
  type    = "A"

  alias {
    name                   = "${var.cluster_alb_dns_name}"
    zone_id                = "${data.aws_alb.cluster_alb.zone_id}"
    evaluate_target_health = true
  }
}

# Create the target group for this service, which will route requests for the
# application to the containers.
resource "aws_alb_target_group" "service" {
  name        = "ecs-${var.service_name}-alb"
  port        = "${var.port}"
  protocol    = "${var.protocol}"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path     = "${var.health_check_url}"
    protocol = "${var.protocol}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Redirect http to https by default.
resource "aws_alb_listener_rule" "service_http" {
  listener_arn    = "${local.http_listener}"

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.service.fqdn}"]
  }

  depends_on = ["aws_alb_target_group.service"]
}

# Listen for https connections and forward them to the target group for load
# balancing.
resource "aws_alb_listener_rule" "service_https" {
  listener_arn = "${local.https_listener}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.service.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.service.fqdn}"]
  }

  depends_on = ["aws_alb_target_group.service"]
}

# Create a local certificate for https.  The machine likely has its own cert,
# but this covers any connections from the world to the load balancer.
resource "aws_alb_listener_certificate" "service" {
  listener_arn    = "${local.https_listener}"
  certificate_arn = "${aws_acm_certificate_validation.cert.certificate_arn}"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${aws_route53_record.service.fqdn}"
  validation_method = "DNS"
}

# Create a validation record for that certificate, so that AWS can verify we do
# own the hostname.
resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.selected.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
