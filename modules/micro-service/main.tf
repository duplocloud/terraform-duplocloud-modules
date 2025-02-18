locals {
  tenant      = data.duplocloud_tenant.this
  config_name = var.config.name != null ? var.config.name : var.name
  image_uri   = var.image.uri != null ? var.image.uri : "${var.image.registry}/${coalesce(var.image.repo, var.name)}:${var.image.tag}"
  # Check if we need to look up the cert arn
  do_cert_lookup = var.lb.enabled && var.lb.certificate != "" && !startswith(var.lb.certificate, "arn:aws:acm:")
  cert_arn       = local.do_cert_lookup ? data.duplocloud_plan_certificate.this[0].arn : var.lb.certificate
  # if the cert_arn is not null and the external port is null, set it to 443, else set it to 80
  external_port = var.lb.port != null ? var.lb.port : local.cert_arn != "" ? 443 : var.lb.type == "service" ? var.port : 80
  alb_types = {
    "elb"                  = 0
    "alb"                  = 1
    "health-only"          = 2
    "service"              = 3
    "node-port"            = 4
    "azure-shared-gateway" = 5
    "nlb"                  = 6
    "target-group"         = 7
  }
  container_context = {
    env_from         = jsonencode(local.env_from)
    image            = var.image
    port             = var.port
    health_check     = var.health_check
    nodeSelector     = jsonencode(var.nodes.selector)
    restart_policy   = var.restart_policy
    annotations      = jsonencode(var.annotations)
    labels           = jsonencode(var.labels)
    pod_labels       = jsonencode(var.pod_labels)
    pod_annotations  = jsonencode(var.pod_annotations)
    resources        = jsonencode(var.resources)
    security_context = jsonencode(var.security_context)
    volume_mounts    = jsonencode(local.volume_mounts)
    command          = jsonencode(var.command)
    args             = jsonencode(var.args)
    # volumes = jsonencode(local.volumes)
  }
  filemap_enabled = var.config.files != {} ? true : false
  filemap_volume = local.filemap_enabled ? [
    {
      name = "config"
      configMap = {
        name = duplocloud_k8_config_map.files[0].name
      }
    }
  ] : []
  volumes = concat(
    local.filemap_volume,
    jsondecode(var.volumes_json)
  )
}

# If the tenant_id is not set, we need to look it up with the tenant data block
data "duplocloud_tenant" "this" {
  name = var.tenant
}

# now check for the cert arn when we need to do_cert_lookup
data "duplocloud_plan_certificate" "this" {
  count   = local.do_cert_lookup ? 1 : 0
  name    = var.lb.certificate
  plan_id = local.tenant.plan_id
}
