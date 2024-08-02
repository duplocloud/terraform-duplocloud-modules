locals {
  tenant_id  = data.duplocloud_tenant.this.id
  account_id = data.duplocloud_aws_account.this.account_id
  region     = data.duplocloud_tenant_aws_region.this.aws_region
}

data "duplocloud_tenant" "this" {
  name = var.tenant_name
}

data "duplocloud_infrastructure" "this" {
  tenant_id = data.duplocloud_tenant.this.id
}

data "duplocloud_aws_account" "this" {}

data "duplocloud_tenant_aws_region" "this" {
  tenant_id = local.tenant_id
}
