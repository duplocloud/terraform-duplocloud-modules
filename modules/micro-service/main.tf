locals {
  tenant      = data.duplocloud_tenant.this
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
  configurations = [
    for config in var.configurations : merge(config, {
      name   = "${var.name}${config.suffix != null ? config.suffix : config.type == "environment" ? "-env" : "-files"}"
    })
  ]
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
    env              = jsonencode(local.container_env)
    # volumes = jsonencode(local.volumes)
  }
  volumes = concat(
    jsondecode(var.volumes_json), []
  )
  # for each key value in var.env make a list of objects with name and value
  container_env = [
    for key, value in var.env : {
      name  = key
      value = value
    }
  ]
  # build from the single env configmap and all of the secret names
  env_from = concat([
    # build an envFrom array for the container from only the type environment var.configurations
    for config in local.configurations : {
      configMapRef : {
        name = config.name
      }
    } if config.type == "environment" && config.class == "configmap"
  ],[
    # build an envFrom array for the container from var.confurations only for type environment and the class can be anything but configmap
    for config in local.configurations : {
      secretRef : {
        name = config.name
      }
    } if (
      config.type == "environment" && 
      (config.class == "secret" || (config.class != "configmap" && config.csi))
    )
  ], [
    for secret in var.secrets : {
      secretRef : {
        name = secret
      }
    }
  ])
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
