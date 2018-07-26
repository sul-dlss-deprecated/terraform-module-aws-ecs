/*====
Route53 record
======*/
resource "aws_route53_record" "service" {
  zone_id = "${var.cluster_zone_id}"
  name    = "${var.service_host}.${var.cluster_zone_name}"
  type    = "A"

  alias {
    name                   = "${var.cluster_alb_dns_name}"
    zone_id                = "${var.cluster_alb_zone_id}"
    evaluate_target_health = true
  }
}

/*====
IAM task role
======*/
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.service_name}-${var.environment}-ecs-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

/*====
ECS task definitions
======*/
resource "aws_ecs_task_definition" "service" {
  family                   = "${var.service_name}"
  container_definitions    = "${var.container_definition}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = "${aws_iam_role.ecs_task_role.arn}"
  execution_role_arn       = "${var.execution_role_arn}"
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"

  lifecycle {
    create_before_destroy = true
  }
}

/*====
Service ALB target group & listener rule
======*/
resource "random_id" "target_group" {
  byte_length = 2
}

resource "aws_alb_target_group" "service" {
  name        = "${var.service_name}-${var.environment}-alb-tg-${random_id.target_group.hex}"
  port        = "${var.port}"
  protocol    = "HTTPS"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "${var.health_check_url}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener_rule" "service_http" {
  listener_arn = "${var.cluster_alb_http_listener_arn}"

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

resource "aws_alb_listener_rule" "service_https" {
  listener_arn = "${var.cluster_alb_https_listener_arn}"

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

resource "aws_alb_listener_certificate" "service" {
  listener_arn    = "${var.cluster_alb_https_listener_arn}"
  certificate_arn = "${aws_acm_certificate_validation.cert.certificate_arn}"
}

/* cert for https listener */
resource "aws_acm_certificate" "cert" {
  domain_name       = "${aws_route53_record.service.fqdn}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.cluster_zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

/*====
Security Group
======*/
resource "aws_security_group" "ecs_service" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.service_name}-${var.environment}-ecs-service-sg"
  description = "Allow egress from container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.port}"
    to_port     = "${var.port}"
    protocol    = "tcp"
    security_groups = ["${var.cluster_alb_security_group_id}"]
  }

  tags {
    Name        = "${var.service_name}-${var.environment}-ecs-service-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.service_name}"
  task_definition = "${aws_ecs_task_definition.service.arn}"
  desired_count   = "${var.min_capacity}"
  launch_type     = "FARGATE"
  cluster         = "${var.cluster_id}"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_service.id}"]
    subnets         = ["${split(",", var.private_subnets)}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.service.arn}"
    container_name   = "${var.service_name}"
    container_port   = "${var.port}"
  }

  # comment this block out if you want to restart the service with changes
  # to the local container_definitions for this service.
  lifecycle {
    ignore_changes = ["desired_count"]
  }

  depends_on = ["aws_alb_target_group.service", "aws_alb_listener_rule.service_http", "aws_alb_listener_rule.service_https"]
}
