module "configurations" {
  for_each = { for idx, config in local.configurations : idx => config }
  source = "../configuration"
  name  = each.value.name
  description = each.value.description
  tenant_id = local.tenant.id
  class = each.value.class
  data = each.value.data
  value = each.value.value
  csi = each.value.csi
  managed = each.value.managed
}

# module "config_env" {
#   count     = var.config.env != {} ? 1 : 0
#   source = "../configuration"
#   name      = "${local.config_name}-env"
#   tenant_id = local.tenant.id
#   class = "configmap"
#   data = var.config.env
#   managed = true
# }

# now build the configmap for the config.files if it exists
# module "config_files" {
#   count     = local.filemap_enabled ? 1 : 0
#   source = "../configuration"
#   name      = "${local.config_name}-files"
#   tenant_id = local.tenant.id
#   class = "configmap"
#   data = var.config.files
#   managed = true
# }

# module "secret_env" {
#   count = var.config.secret_env != {} ? 1 : 0
#   source = "../configuration"
#   name  = "${local.config_name}-env"
#   tenant_id = local.tenant.id
#   class = "aws-secret"
#   data = var.config.secret_env
#   csi = true
#   managed = false
# }

