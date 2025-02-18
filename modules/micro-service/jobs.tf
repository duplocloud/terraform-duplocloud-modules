locals {
  job_id = var.jobs.id != null ? var.jobs.id : random_string.job_id[0].id
}

resource "random_string" "job_id" {
  count = var.jobs.id == null ? 1 : 0
  keepers = {
    uuid = uuid()
  }
  length = 5
  special = false
  upper = false
}

# the before update job
resource "duplocloud_k8s_job" "before_update" {
  count     = var.jobs.before_update.enabled ? 1 : 0
  tenant_id = local.tenant.id
  is_any_host_allowed = var.nodes.shared
  wait_for_completion = var.jobs.before_update.wait
  metadata {
    name = "${var.name}${var.jobs.before_update.suffix}-${local.job_id}"
    annotations = var.annotations
    labels = var.labels
  }
  spec {
    template {
      metadata {
        annotations = var.pod_annotations
        labels = var.pod_labels
      }
      spec {
        node_selector = var.nodes.selector
        restart_policy = var.restart_policy
        security_context {
          fs_group = var.security_context.fs_group
          run_as_group = var.security_context.run_as_group
          run_as_user = var.security_context.run_as_user
        }
        container {
          name  = "before_update"
          image = local.image_uri
          command = coalesce(var.jobs.before_update.command, var.command)
          args = var.jobs.before_update.args
          env {
            name  = "JOB_ID"
            value = local.job_id
          }
          env_from {
            # add the non secret tf managed env vars
            dynamic "config_map_ref" {
              for_each = var.config.env != {} ? [1] : []
              content {
                name = duplocloud_k8_config_map.env.name
              }
            }
            # add the secret tf non managed env vars
            dynamic "secret_ref" {
              for_each = var.config.secrets
              content {
                name = secret.value
              }
            }
            # add the named env from secrets
            dynamic "secret_ref" {
              for_each = var.config.secrets
              content {
                name = secret.value
              }
            }
          }
        }
      }
    }
  }
}
