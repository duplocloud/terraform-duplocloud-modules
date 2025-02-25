resource "duplocloud_k8_secret" "managed" {
  count              = var.managed && var.class == "secret" ? 1 : 0
  tenant_id          = var.tenant_id
  secret_name        = local.name
  secret_type        = "Opaque"
  secret_data        = local.data
  secret_annotations = local.annotations
  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
}

resource "duplocloud_k8_secret" "unmanaged" {
  count              = var.managed && var.class == "secret" ? 1 : 0
  tenant_id          = var.tenant_id
  secret_name        = local.name
  secret_type        = "Opaque"
  secret_data        = local.data
  secret_annotations = local.annotations
  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
  lifecycle {
    ignore_changes = [
      secret_data
    ]
  }
}
