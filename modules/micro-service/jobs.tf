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
            for_each = local.env_from
            content {
              # do the same for the configmaps
              dynamic "config_map_ref" {
                for_each = contains(keys(env_from.value), "configMapRef") ? [env_from.value.configMapRef] : []
                content {
                  name = config_map_ref.value.name
                }
              }
              # use a dynamic block to add the secret ref if the envFrom has a key named secret_ref
              dynamic "secret_ref" {
                for_each = contains(keys(env_from.value), "secretRef") ? [env_from.value.secretRef] : []
                content {
                  name = secret_ref.value.name
                }
              }
            }
          }
          # now the volume mounts
          dynamic "volume_mount" {
            for_each = local.volume_mounts
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mountPath
              read_only = volume_mount.value.readOnly
            }
          }
        }
        dynamic "volume" {
          for_each = local.volumes
          content {
            name = volume.value.name
            dynamic "config_map" {
              for_each = contains(keys(volume.value), "configMap") ? [volume.value.configMap] : []
              content {
                name = config_map.value.name
              }
            }
            dynamic "secret" {
              for_each = contains(keys(volume.value), "secret") ? [volume.value.secret] : []
              content {
                secret_name = secret.value.secretName
              }
            }
            dynamic "csi" {
              for_each = contains(keys(volume.value), "csi") ? [volume.value.csi] : []
              content {
                driver    = csi.value.driver
                read_only = csi.value.readOnly
                volume_attributes = csi.value.volumeAttributes
              }
            }
          }
        }
      }
    }
  }
}
