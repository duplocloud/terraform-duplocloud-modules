locals {
  # build this here so we can decode the generated json first before re-encoding it later in the service
  other_docker_config = jsondecode(templatefile("${path.module}/service.json", {
    env_from     = jsonencode(local.env_from)
    image        = var.image
    port         = var.port
    health_check = var.health_check
  }))
}

resource "duplocloud_duplo_service" "this" {
  tenant_id                            = local.tenant.id
  name                                 = var.name
  replicas                             = var.replicas
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
