locals {
  # either the tenant_id is set or we need to get it from the data block
  tenant = data.duplocloud_tenant.this
  config_name = var.config.name != null ? var.config.name : var.name
  # Check if we need to look up the cert arn
  do_cert_lookup = var.lb.enabled && var.lb.certificate != "" && !startswith(var.lb.certificate, "arn:aws:acm:")
  cert_arn       = local.do_cert_lookup ? data.duplocloud_plan_certificate.this[0].arn : var.lb.certificate
  # if the cert_arn is not null and the external port is null, set it to 443, else set it to 80
  external_port = var.lb.port != null ? var.lb.port : local.cert_arn != null ? 443 : 80
  alb_types = {
    "elb"                  = 0
    "alb"                  = 1
    "health-only"          = 2
    "service"              = 3
    "node-port"            = 4
    "azure-shared-gateway" = 5
    "nlb"                  = 6
    "target-group"         = 7
  }
}

# If the tenant_id is not set, we need to look it up with the tenant data block
data "duplocloud_tenant" "this" {
  name = var.tenant
}

# now check for the cert arn when we need to do_cert_lookup
data "duplocloud_plan_certificate" "this" {
  count   = local.do_cert_lookup ? 1 : 0
  name    = var.lb.certificate
  plan_id = local.tenant.plan_id
}
