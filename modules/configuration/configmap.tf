resource "duplocloud_k8_config_map" "managed" {
  count     = var.managed && var.class == "configmap" ? 1 : 0
  tenant_id = var.tenant_id
  name      = var.name
  data      = local.data
  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
}

resource "duplocloud_k8_config_map" "unmanaged" {
  count     = !var.managed && var.class == "configmap" ? 1 : 0
  tenant_id = var.tenant_id
  name      = var.name
  data      = local.data
  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
  lifecycle {
    ignore_changes = [
      data
    ]
  }
}
