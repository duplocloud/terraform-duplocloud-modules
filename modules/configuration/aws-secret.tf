

resource "duplocloud_tenant_secret" "managed" {
  count       = var.managed && var.class == "aws-secret" ? 1 : 0
  tenant_id   = var.tenant_id
  name_suffix = var.name
  data        = local.data
}

resource "duplocloud_tenant_secret" "unmanaged" {
  count       = !var.managed && var.class == "aws-secret" ? 1 : 0
  tenant_id   = var.tenant_id
  name_suffix = var.name
  data        = local.data
  lifecycle {
    ignore_changes = [
      data
    ]
  }
}
