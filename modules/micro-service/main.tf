resource "duplocloud_k8_config_map" "this" {
  tenant_id = var.tenant_id
  name      = var.name
  data      = jsonencode(var.env)
  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
}

resource "duplocloud_duplo_service" "this" {
  tenant_id                            = var.tenant_id
  name                                 = var.name
  replicas                             = var.replicas
  lb_synced_deployment                 = false
  cloud_creds_from_k8s_service_account = true
  is_daemonset                         = false
  agent_platform                       = 7
  cloud                                = 0
  other_docker_config = jsonencode({
    EnvFrom = concat([
      {
          "configMapRef" : {
            "name" : duplocloud_k8_config_map.this.name
          }
        }
    ],[
      for secret in var.env_secrets : {
        secretRef : {
          name = secret
        }
      }
    ])
    "Resources" : {},
    "RestartPolicy" : "Always"
    "ImagePullPolicy" : "Always",
    "LivenessProbe" : {
      "failureThreshold" : 3,
      "initialDelaySeconds" : 15,
      "periodSeconds" : 20,
      "successThreshold" : 1,
      "tcpSocket" : {
        "port" : 3001
      },
      "timeoutSeconds" : 1
    },
    "PodSecurityContext" : {},
    "ReadinessProbe" : {
      "failureThreshold" : 3,
      "initialDelaySeconds" : 10,
      "periodSeconds" : 10,
      "successThreshold" : 1,
      "tcpSocket" : {
        "port" : 3001
      },
      "timeoutSeconds" : 1
    }
  })
  docker_image = var.image
  lifecycle {
    ignore_changes = [
      docker_image
    ]
  }
}

resource "duplocloud_duplo_service_lbconfigs" "this" {
  tenant_id                   = var.tenant_id
  replication_controller_name = duplocloud_duplo_service.this.name
  lbconfigs {
    lb_type          = 7
    is_native        = false
    is_internal      = false
    port             = var.lb_config.port
    external_port    = var.lb_config.port
    protocol         = "http"
    health_check_url = var.lb_config.health_check_url
  }
}

resource "duplocloud_aws_lb_listener_rule" "this" {
  tenant_id    = var.tenant_id
  listener_arn = var.lb_config.listener_arn
  priority     = var.lb_config.priority
  action {
    type             = "forward"
    target_group_arn = duplocloud_duplo_service_lbconfigs.this.lbconfigs[0].target_group_arn
  }
  condition {
    path_pattern {
      values = [var.lb_config.path_pattern]
    }
  }
  depends_on = [ 
    duplocloud_duplo_service_lbconfigs.this
  ]
}
