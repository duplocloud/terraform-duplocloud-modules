locals {
  tenant_id   = data.duplocloud_tenant.this.id
  shortname   = "${var.tenant_name}-${var.name}"
  fullname    = "duplo-${local.shortname}"
  namespace   = "duploservices-${var.tenant_name}"
  sg_infra    = tolist(data.duplocloud_infrastructure.this.security_groups)
  base_domain = data.duplocloud_plan_settings.this.dns_setting.external_dns_suffix
  domain      = "${local.shortname}.${local.base_domain}"
  zone_id     = data.duplocloud_plan_settings.this.dns_setting.domain_id
  base_tags = {
    TENANT_NAME   = var.tenant_name
    duplo-project = var.tenant_name
  }
}

data "duplocloud_tenant" "this" {
  name = var.tenant_name
}

data "duplocloud_infrastructure" "this" {
  tenant_id = data.duplocloud_tenant.this.id
}

data "aws_security_group" "tenant" {
  name = local.namespace
}

data "duplocloud_plan_settings" "this" {
  plan_id = data.duplocloud_tenant.this.plan_id
}

data "duplocloud_plan_certificate" "this" {
  name    = var.cert_name
  plan_id = data.duplocloud_tenant.this.plan_id
}
