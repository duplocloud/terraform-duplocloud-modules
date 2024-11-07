locals {
  tenant_id = data.duplocloud_tenant.this.id
}

data "duplocloud_tenant" "this" {
  name = var.tenant_name
}