locals {
  tenant_id   = data.duplocloud_tenant.this.id
  shortname   = "${var.tenant_name}-${var.name}"
  fullname    = "duplo-${local.shortname}"
  namespace   = "duploservices-${var.tenant_name}"
  sg_infra    = tolist(data.duplocloud_infrastructure.this.security_groups)
  base_domain = data.duplocloud_plan_settings.this.dns_setting[0].external_dns_suffix
  domain      = "${local.shortname}${local.base_domain}"
  zone_id     = data.duplocloud_plan_settings.this.dns_setting[0].domain_id
  base_tags = {
    TENANT_NAME   = var.tenant_name
    duplo-project = var.tenant_name
  }
  body_vars = merge(var.openapi_variables, {
    AWS_ACCOUNT_ID = data.duplocloud_aws_account.this.account_id
    AWS_REGION     = data.duplocloud_infrastructure.this.region
    DUPLO_TENANT   = var.tenant_name
    DOMAIN         = local.domain
  })
  body = var.body != null ? var.body : var.openapi_file == null ? null : yamlencode(yamldecode(templatefile(var.openapi_file, local.body_vars)))
}

data "duplocloud_aws_account" "this" {}

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

data "duplocloud_tenant_internal_subnets" "this" {
  tenant_id = local.tenant_id
}
