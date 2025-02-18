resource "duplocloud_tenant_secret" "this" {
  tenant_id = var.tenant_id
  name_suffix = var.name

  data = jsonencode(var.data)

  lifecycle {
    ignore_changes = [
      data
    ]
  }
}
