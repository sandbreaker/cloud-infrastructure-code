/*
Public LB security group
*/
resource "aws_security_group" "elb_public" {
  name        = "${var.env}-elb-public"
  description = "Public ELB"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # All ports for itself
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port = 8800
    to_port   = 8800
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 8443
    to_port   = 8443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name        = "${var.env}-elb-public-sg"
    Environment = var.env
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*
 Private LB security group
*/
resource "aws_security_group" "elb_private" {
  name        = "${var.env}-elb-private"
  description = "Private ELB"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # All ports for itself
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 8800
    to_port   = 8800
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 8443
    to_port   = 8443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name        = "${var.env}-elb-private-sg"
    Environment = var.env
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*
 Public LB
*/
resource "aws_lb" "lb_public" {
  name                             = "${var.env}-public"
  load_balancer_type               = "application"
  internal                         = false
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  enable_http2                     = true

  security_groups = [
    aws_security_group.elb_public.id,
  ]

  subnets = var.public_subnets

  # enable bucket policy from s3 module
  # access_logs {
  #   bucket = "${var.corp}-log"
  #   prefix = "AWSLogs/${var.env}/elb-public"
  # }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

// Empty target group, default/required listener for a default action
resource "aws_lb_target_group" "empty_default_public" {
  name = "${var.env}-empty-default-public"

  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "port80_public" {
  load_balancer_arn = aws_lb.lb_public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

/*
resource "aws_lb_listener" "port443_public" {
  # Use `aws_lb_listener_rule(s)` with "host-header" conditions

  load_balancer_arn = aws_lb.lb_public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  # Note that cert needs to be created manually from AWS console
  # Generally good to create wildcard like "*.yourdomain.com"
  certificate_arn = var.lb_public_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.empty_default_public.arn
    type             = "forward"
  }
}
*/

/*
 Private LB
*/
resource "aws_lb" "lb_private" {
  name                             = "${var.env}-private"
  load_balancer_type               = "application"
  internal                         = true
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  enable_http2                     = true

  security_groups = [
    aws_security_group.elb_private.id,
  ]

  subnets = var.private_subnets

  # enable bucket policy from s3 module
  # access_logs {
  #   bucket = "${var.corp}-log"
  #   prefix = "AWSLogs/${var.env}/elb-private"
  # }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

// Empty target group, default/required listener for a default action
resource "aws_lb_target_group" "empty_default_private" {
  name = "${var.env}-empty-default-private"

  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "port80_private" {
  load_balancer_arn = aws_lb.lb_private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

/*
resource "aws_lb_listener" "port443_private" {
  # Use `aws_lb_listener_rule(s)` with "host-header" conditions

  load_balancer_arn = aws_lb.lb_private.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  # Note that cert needs to be created manually from AWS console
  # Generally good to create wildcard like "*.<production|staging>-private.yourdomain.com"
  certificate_arn = var.lb_private_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.empty_default_private.arn
    type             = "forward"
  }
}
*/


