locals {
  # build this here so we can decode the generated json first before re-encoding it later in the service
  other_docker_config = jsondecode(templatefile("${path.module}/service.json", {
    env_from     = jsonencode(local.env_from)
    image        = var.image
    port         = var.port
    health_check = var.health_check
    nodeSelector = jsonencode(var.nodes.selector)
    restart_policy = var.restart_policy
    annotations = jsonencode(var.annotations)
    labels = jsonencode(var.labels)
    pod_labels = jsonencode(var.pod_labels)
    pod_annotations = jsonencode(var.pod_annotations)
    resources = jsonencode(var.resources)
    security_context = jsonencode(var.security_context)
    # volume_mounts = jsonencode(var.volume_mounts)
    # volumes = jsonencode(local.volumes)
  }))
  # volumes = concat(jsondecode(var.volumes_json), var.config.files == {} ? [] : [
  #   {
  #     name = "config"
  #     configMap = {
  #       name = duplocloud_k8_config_map.files[0].name
  #     }
  #   }
  # ])
}

resource "duplocloud_duplo_service" "this" {
  tenant_id                            = local.tenant.id
  name                                 = var.name
  replicas                             = var.replicas
  allocation_tags                      = var.nodes.allocation_tags
  any_host_allowed                     = var.nodes.shared
  lb_synced_deployment                 = false
  cloud_creds_from_k8s_service_account = true
  is_daemonset                         = false
  agent_platform                       = 7
  cloud                                = 0
  other_docker_config                  = jsonencode(local.other_docker_config)
  docker_image                         = var.image.uri
  lifecycle {
    ignore_changes = [
      docker_image
    ]
  }
}
