output "id" {
  description = "The ID of the configuration. This is only used for the name of a volume mounted on a service."
  value = local.id
}

output "name" {
  description = "The actual name of the configuration."
  value = nonsensitive(local.realName)
  sensitive = false
}

output "type" {
  description = "The type configuration."
  value = var.type
}

output "csi" {
  description = "Whether or not the configuration is a CSI configuration. This may be different than the input because some classes don't support CSI."
  value = local.csi
}

output "enabled" {
  description = "Whether or not the configuration is enabled."
  value = var.enabled
  
}

output "class" {
  description = "The class of the configuration."
  value = var.class
}

output "envFrom" {
  description = "The envFrom configuration if the configuration is of type environment and enabled."
  value = length(local.envFrom) > 0 ? local.envFrom[0] : null
  # value = (
  #   var.enabled && var.type == "environment"
  # ) ? var.class == "configmap" ? {
  #   configMapRef = {
  #     name = local.realName
  #   }
  # } : {
  #   secretRef = {
  #     name = local.realName
  #   }
  # } : null
}

output "volume" {
  description = "The volume configuration if the configuration is of type files and enabled. Even when type is environment, if csi is enabled then a volume is also needed."
  # for each of the key values in local.volumes, if the value is not null, then return the value
  value = length(local.volume) > 0 ? local.volume[0] : null
  sensitive = false
}

output "volumeMount" {
  description = "The volume mount configuration if the configuration is of type files and enabled. Even when type is environment, if csi is enabled then a volume mount is also needed."
  value = (
    var.enabled && (var.type == "files" || local.csi)
  ) ? {
    name      = local.id
    mountPath = local.mountPath
    readOnly  = true
  } : null
}
