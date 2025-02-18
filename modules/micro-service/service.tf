locals {
  service = var.image.managed ? duplocloud_duplo_service.managed[0] : duplocloud_duplo_service.unmanaged[0]
  # build this here so we can decode the generated json first before re-encoding it later in the service
  other_docker_config = jsondecode(templatefile("${path.module}/templates/service.json", local.container_context))
  volume_mounts = concat(var.volume_mounts, [])
}

# the tf managed resource block
resource "duplocloud_duplo_service" "managed" {
  count                                = var.image.managed ? 1 : 0
  tenant_id                            = local.tenant.id
  name                                 = var.name
  replicas                             = var.scale.replicas
  allocation_tags                      = var.nodes.allocation_tags
  any_host_allowed                     = var.nodes.shared
  lb_synced_deployment                 = false
  cloud_creds_from_k8s_service_account = true
  is_daemonset                         = false
  agent_platform                       = 7
  cloud                                = 0
  other_docker_config                  = jsonencode(local.other_docker_config)
  docker_image                         = local.image_uri
}

# this services image and maybe the other docker config is not managed by tf
# this expectes you are using the duploctl cli to update these after tf runs
resource "duplocloud_duplo_service" "unmanaged" {
  count                                = var.image.managed ? 0 : 1
  tenant_id                            = local.tenant.id
  name                                 = var.name
  replicas                             = var.scale.replicas
  allocation_tags                      = var.nodes.allocation_tags
  any_host_allowed                     = var.nodes.shared
  lb_synced_deployment                 = false
  cloud_creds_from_k8s_service_account = true
  is_daemonset                         = false
  agent_platform                       = 7
  cloud                                = 0
  other_docker_config                  = jsonencode(local.other_docker_config)
  docker_image                         = local.image_uri
  lifecycle {
    ignore_changes = [
      docker_image
    ]
  }
}
