
# the standalone alb itself
resource "duplocloud_aws_load_balancer" "standalone" {
  tenant_id            = var.tenant_id
  name                 = var.name
  load_balancer_type   = "application"
  enable_access_logs   = false
  is_internal          = true
  drop_invalid_headers = false
  idle_timeout         = var.timeout
}

# duplo bug prevents deletion of target group, it must prefix custom-
resource "duplocloud_aws_lb_target_group" "default" {
  tenant_id   = var.tenant_id
  name        = "custom-${var.name}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 3
    interval            = 300
    path                = var.health_path
    port                = "80"
    protocol            = "HTTP"
    timeout             = var.timeout
    unhealthy_threshold = 3
  }
}

resource "duplocloud_aws_load_balancer_listener" "https" {
  tenant_id          = var.tenant_id
  load_balancer_name = duplocloud_aws_load_balancer.standalone.name
  certificate_arn    = var.cert_arn
  protocol           = "HTTPS"
  port               = 443
  target_group_arn   = duplocloud_aws_lb_target_group.default.arn
}

resource "duplocloud_aws_lb_listener_rule" "default" {
  tenant_id    = var.tenant_id
  listener_arn = duplocloud_aws_load_balancer_listener.https.arn
  priority     = 97
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY"
      status_code  = "200"
    }
  }
  condition {
    path_pattern {
      values = [
        var.health_path
      ]
    }
  }
}


