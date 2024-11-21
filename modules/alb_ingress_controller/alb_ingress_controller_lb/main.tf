
resource "duplocloud_duplo_service_lbconfigs" "serverlbs" {
  tenant_id = var.tenant_id

  replication_controller_name = var.service_name

  lbconfigs {
    external_port               = var.lb_external_port
    health_check_url            = var.lb_health_check_url
    is_native                   = false
    lb_type                     = 3   #K8S Service w/ Node Port (No Load Balancer)
    port                        = var.lb_port
    protocol                    = var.lb_protocol
  }

  # Workaround for AWS:  Even after the ALB is available, there is some short duration where a V2 WAF cannot be attached.
  provisioner "local-exec" {
    command = "sleep 10"
  }
}


# Create the AWS Load Balancer Controller:
resource "duplocloud_k8_ingress" "ingress" {
  tenant_id          = var.tenant_id
  name               = "${var.service_name}-ingress"
  ingress_class_name = "alb"
  lbconfig {
    is_internal     = var.is_lb_internal
    dns_prefix      = "${var.dns_prefix}.${var.tenant_subdomain}"
    certificate_arn = var.cert_arn
    https_port      = 443
    http_port       = 80
  }

  dynamic "rule" {
    for_each = concat(
      [
        "api.${local.tenant_internal_fqdn}", 
        local.wemlo_api_fqdn
      ],
      keys(local.wemlo_api_vanity_fqdns)
    )
    content {
      host         = rule.value
      path         = "/"
      path_type    = "Prefix"
      service_name = duplocloud_duplo_service.server.name
      port         = 3000
    }
  }

  dynamic "rule" {
    for_each = local.is_prod_tenant ? [] : [1]  # Conditionally include rule block
    content {
      host         = local.tenant_fqdn
      path         = "/"
      path_type    = "Prefix"
      service_name = "redirect-to-app"
      port_name    = "use-annotation"
    }
  }

  dynamic "rule" {
    for_each = values(local.vanity_redirect_rules)

    content {
      host         = rule.value.host
      path         = rule.value.path
      path_type    = rule.value.path_type
      service_name = rule.value.service_name
      port_name    = rule.value.port_name
    }
  }

   annotations = merge(
   {
    "alb.ingress.kubernetes.io/backend-protocol": "${var.backend_protocol}",
    "alb.ingress.kubernetes.io/target-type": "ip",
    "alb.ingress.kubernetes.io/healthcheck-path": "${var.health_check}",
    "alb.ingress.kubernetes.io/healthcheck-interval-seconds": "5",
    "alb.ingress.kubernetes.io/healthy-threshold-count": "2",
    "alb.ingress.kubernetes.io/healthcheck-timeout-seconds": "4",
    "alb.ingress.kubernetes.io/target-group-attributes": "deregistration_delay.timeout_seconds=30",
    "alb.ingress.kubernetes.io/wafv2-acl-arn": var.disable_waf ? "" : var.waf_v2_arn,
    # Note all load balancer attributes are a comma spearated list as opposed to separate attribute entries. Docs don't say this, this may be the case with target group attributes as well
    "alb.ingress.kubernetes.io/load-balancer-attributes": "access_logs.s3.enabled=${var.enable_access_logs},access_logs.s3.bucket=duplo-${local.duplo_plan_id}-awslogs-${data.aws_caller_identity.current.account_id},access_logs.s3.prefix=ELB,idle_timeout.timeout_seconds=${var.wemlo_server_lb_idle_timeout}",
   },
   local.is_prod_tenant ? {} : {
    "alb.ingress.kubernetes.io/actions.redirect-to-app" = jsonencode({
      Type = "redirect",
      RedirectConfig = {
        Host       = local.wemlo_ui_fqdn,
        Path       = "/#{path}",
        Port       = "443",
        Protocol   = "HTTPS",
        Query      = "#{query}",
        StatusCode = "HTTP_301"
      }
    })
   },
    length(local.vanity_domains_list) > 0 ? local.merged_annotation_map : {}
  )

  provisioner "local-exec" {
    command = "sleep 30"
  }
}
