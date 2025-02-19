# do the before update jobs
resource "duplocloud_k8s_job" "before_update" {
  for_each            = { for job in var.jobs : "${job.name != null ? job.name : job.event}" => job if job.enabled && job.event == "before-update" }
  tenant_id           = local.tenant.id
  is_any_host_allowed = var.nodes.shared
  wait_for_completion = each.value.wait
  metadata {
    name        = "${var.name}-${each.value.name != null ? each.value.name : each.value.event}-${local.release_id}"
    annotations = var.annotations
    labels      = var.labels
  }
  spec {
    template {
      metadata {
        annotations = var.pod_annotations
        labels      = var.pod_labels
      }
      spec {
        node_selector  = var.nodes.selector
        restart_policy = "OnFailure"
        security_context {
          fs_group     = var.security_context.fs_group
          run_as_group = var.security_context.run_as_group
          run_as_user  = var.security_context.run_as_user
        }
        container {
          name    = "before-update"
          image   = local.image_uri
          command = coalesce(each.value.command, var.command)
          args    = each.value.args
          env {
            name  = "RELEASE_ID"
            value = local.release_id
          }
          dynamic "env" {
            for_each = var.env
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env_from" {
            for_each = [
              for config in local.configurations : config
              if config.envFromWith == "configmap"
            ]
            content {
              config_map_ref {
                name = env_from.value.name
              }
            }
          }
          dynamic "env_from" {
            for_each = [
              for config in local.configurations : config
              if(config.envFromWith == "secret" || (config.csiMount && config.type == "environment"))
            ]
            content {
              secret_ref {
                name = env_from.value.name
              }
            }
          }
          dynamic "env_from" {
            for_each = var.secrets
            content {
              secret_ref {
                name = env_from.value
              }
            }
          }
          # now the volume mounts for the var.volume_mount
          dynamic "volume_mount" {
            for_each = var.volume_mounts
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mountPath
            }
          }
          # now the volume mounts for the configurations
          dynamic "volume_mount" {
            for_each = [
              for config in local.configurations : config
              if config.enabled && (config.mountWith != null || config.csiMount)
            ]
            content {
              name       = volume_mount.value.id
              mount_path = volume_mount.value.mountPath
            }
          }
        }
        # first mount the configmap file volumes
        dynamic "volume" {
          for_each = [
            for config in local.configurations : config
            if config.mountWith == "configmap"
          ]
          content {
            name = volume.value.id
            config_map {
              name = volume.value.name
            }
          }
        }
        # then mount the secret file volumes
        dynamic "volume" {
          for_each = [
            for config in local.configurations : config
            if config.mountWith == "secret"
          ]
          content {
            name = volume.value.id
            secret {
              secret_name = volume.value.name
            }
          }
        }
        # now the csi volumes
        dynamic "volume" {
          for_each = [
            for config in local.configurations : config
            if config.csiMount
          ]
          content {
            name = volume.value.id
            csi {
              driver    = "secrets-store.csi.k8s.io"
              read_only = true
              volume_attributes = {
                secretProviderClass = volume.value.name
              }
            }
          }
        }
      }
    }
  }
}
