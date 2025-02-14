locals {
  # build from the single env configmap and all of the secret names
  env_from = concat([
    {
      "configMapRef" : {
        "name" : duplocloud_k8_config_map.env.name
      }
    }
    ], [
    for secret in var.config.secrets : {
      secretRef : {
        name = secret
      }
    }
  ])
}

resource "duplocloud_k8_config_map" "env" {
  tenant_id = local.tenant.id
  name      = "${local.config_name}-env"
  data      = jsonencode(var.config.env)
  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
}

# now build the configmap for the config.files if it exists
resource "duplocloud_k8_config_map" "files" {
  count     = var.config.files != null ? 1 : 0
  tenant_id = local.tenant.id
  name      = "${local.config_name}-files"
  data      = jsonencode(var.config.files)
  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
  
}

# the configurable secret. The data is ignored so users can change on the fly
resource "duplocloud_tenant_secret" "this" {
  tenant_id = local.tenant.id
  name_suffix = "${local.config_name}-env"

  data = jsonencode(var.config.secret_env)

  lifecycle {
    ignore_changes = [
      data
    ]
  }
}
