variable "tenant" {
  type        = string
  description = "The name of the tenant."
}

variable "name" {
  type = string
}

variable "command" {
  type    = list(string)
  default = []
}

variable "args" {
  type    = list(string)
  default = []
}

variable "port" {
  description = "The port number the app listens on. This is used for healthchecks on the lb and pod."
  type        = number
  default     = 80
}

variable "env" {
  description = "The environment variables to set on the container of the service."
  type        = map(string)
  default     = {}
}

variable "image" {
  description = <<EOT
  The configuration for which image and how to handle it.
  This includes the pull policy and the URI of the image. 

  If `uri` is set then this is used. Otherwise set the `repo`, `registry`, and `tag` to build the URI. If none of these values are set, then it's assumed the app name is the repo, the registry is docker.io, and the tag is latest, ie `docker.io/myapp:latest`.

  The `pullPolicy` field determines how the image is pulled. It can be one of the following: `Always`, `IfNotPresent`, or `Never`.

  The `managed` field determines if the images is updated by Terraform or not. If it is not managed, the image will not be updated by Terraform and it's expected you are using the duploctl CLI to update the image.
  EOT
  type = object({
    uri        = optional(string, null)
    tag        = optional(string, "latest")
    repo       = optional(string, null)
    registry   = optional(string, "docker.io")
    pullPolicy = optional(string, "IfNotPresent")
    managed    = optional(bool, true)
  })
  default = {}
  validation {
    condition     = can(regex("^(Always|IfNotPresent|Never)$", var.image.pullPolicy))
    error_message = "The pull policy must be one of 'Always', 'IfNotPresent', or 'Never'"
  }
}

variable "scale" {
  description = <<EOT
  The configuration for how to scale the service.
  This includes the replicas, min, and max.

  The `auto` field determines if the service should be autoscaled. If it is not autoscaled, the replicas field will be used.

  The metrics field is a list of metrics to use for autoscaling. This includes the type and target.
  EOT
  type = object({
    auto     = optional(bool, false)
    replicas = optional(number, 1)
    min      = optional(number, 1)
    max      = optional(number, 3)
    metrics = optional(list(object({
      type   = string
      target = number
    })), [])
  })
  default = {}

  # make sure max is always greater than min
  validation {
    condition     = var.scale.max >= var.scale.min
    error_message = "The max must be greater than the min."
  }

  # the replicas must be between min and max
  validation {
    condition     = var.scale.replicas >= var.scale.min && var.scale.replicas <= var.scale.max
    error_message = "The replicas must be greater than or equal to min and less than or equal to max."
  }
}

variable "restart_policy" {
  type    = string
  default = "Always"
  validation {
    condition     = can(regex("^(Always|OnFailure|Never)$", var.restart_policy))
    error_message = "The restart policy must be one of 'Always', 'OnFailure', or 'Never'"
  }
}

variable "annotations" {
  description = "Annotations to add to the service."
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to add to the service."
  type        = map(string)
  default     = {}
}

variable "pod_annotations" {
  description = "Annotations to add to the pod."
  type        = map(string)
  default     = {}
}

variable "pod_labels" {
  description = "Labels to add to the pod."
  type        = map(string)
  default     = {}
}

variable "resources" {
  description = "The resource requests and limits for the service."
  type = object({
    requests = optional(map(string))
    limits   = optional(map(string))
  })
  default = {}
}

variable "security_context" {
  description = "The security context for the service."
  type = object({
    run_as_user  = optional(number, null)
    run_as_group = optional(number, null)
    fs_group     = optional(number, null)
  })
  default = {}
}

variable "nodes" {
  description = <<EOT
  The configuration for which nodes to run the service on.
  EOT
  type = object({
    allocation_tags = optional(string, null)
    shared          = optional(bool, false)
    selector        = optional(map(string), {})
  })
  default = {}
}

variable "lb" {
  description = <<EOT
Expose the service via a load balancer. 

Use the `enabled` field to enable or disable the load balancer.

The type of load balancer can be one of the following: 
- elb
- alb
- health-only
- service
- node-port
- azure-shared-gateway
- nlb
- target-group

The `certificate` field will determine if the LB is HTTPS or not. If the field is not set, the LB will be HTTP.
The value can be an ARN or a string that matches the certificate name in the AWS Certificate Manager. If the field is a name, the duplo provider will look up the ARN for you.

The `external_port` field will determine the port that the load balancer will listen on. If the field is not set, the port will be 80 for HTTP and 443 for HTTPS depending on weether or not the `certificate` field is set.

If the type is `target-group`, the `listener` field must be set to the ARN of the listener that the target group will be attached to.

See more docs here: https://registry.terraform.io/providers/duplocloud/duplocloud/latest/docs/resources/duplo_service_lbconfigs
EOT
  type = object({
    enabled      = optional(bool, false)
    type         = optional(string, "service")
    priority     = optional(number, 0)
    path_pattern = optional(string, "/*")
    port         = optional(number, null)
    protocol     = optional(string, "http")
    certificate  = optional(string, "")
    listener     = optional(string, null)
  })
  default = {}
  validation {
    condition     = can(regex("^(elb|alb|health-only|service|node-port|azure-shared-gateway|nlb|target-group)$", var.lb.type))
    error_message = "The load balancer type must be one of 'elb', 'alb', 'health-only', 'service', 'node-port', 'azure-shared-gateway', 'nlb', or 'target-group'"
  }
  validation {
    condition     = can(regex("^(http|https|tcp)$", var.lb.protocol))
    error_message = "The protocol must be one of 'http', 'https', or 'tcp'"
  }
  validation {
    condition     = var.lb.type == "target-group" ? var.lb.listener != null : true
    error_message = "The listener must be set when the load balancer type is 'target-group'"
  }
}

variable "health_check" {
  description = <<EOT

  The health check configuration for the service. This includes the path, failureThreshold, initialDelaySeconds, periodSeconds, successThreshold, and timeoutSeconds.

  The `enabled` field will determine if the health check is enabled or not. If the field is not set, the health check will be enabled.

  The `path` field will determine the path that the health check will use. If the field is not set, the path will be "/".

  EOT
  type = object({
    enabled             = optional(bool, true)
    path                = optional(string, "/")
    failureThreshold    = optional(number, 3)
    initialDelaySeconds = optional(number, 15)
    periodSeconds       = optional(number, 20)
    successThreshold    = optional(number, 1)
    timeoutSeconds      = optional(number, 1)
  })
  default = {}
}

# variable "config" {
#   description = <<EOT
#   The configuration for the service. This includes the name, environment variables, and files.

#   The name here can be null, if so the services name will be used. 

#   The `env` field is a map of environment variables that will be added to the service by creating a ConfigMap and mounting it as envFrom. This is the ideal place to set an environment variable which can be determined within the terraform code. This is not the ideal place to store sensitive data nor data you would like to manually control after the initial deployment, use `secret_env` instead.

#   The `secret_env` field is a map of environment variables that will be added to the service by creating a Secret and mounting it as envFrom. The data is ignored so this is the ideal place to store sensitive data as well as data you would like to manually control after the initial deployment.

#   The `files` field is a map of files that will be added to the service by creating a ConfigMap and mounting it as a volume. The key is the path to the file and the value is the content of the file.
#   EOT
#   type = object({
#     name       = optional(string, null)
#     env        = optional(map(string), {})
#     mountPath  = optional(string, "/config")
#     files      = optional(map(string), {})
#     secrets    = optional(list(string), [])
#     secret_env = optional(map(string), {})
#   })
#   default = {}
# }

variable "secrets" {
  description = "The list of external secret names to be mounted as envFrom."
  type        = list(string)
  default     = []
}

variable "configurations" {
  type = list(object({
    suffix  = optional(string, null)
    description = optional(string, null)
    type    = optional(string, "environment") # environment or file
    data    = optional(map(string), {})
    value   = optional(string, null)
    managed = optional(bool, true)
    class   = optional(string, "configmap")
    csi     = optional(bool, false)
  }))
  default = []
}

variable "volume_mounts" {
  description = <<EOT
  The volume mounts for the service. This includes the name, mountPath, and subPath.

  The `name` field is the name of the volume mount.

  The `mountPath` field is the path to mount the volume to.

  The `subPath` field is the path to the file to mount.
  EOT
  type = list(object({
    name      = string
    mountPath = string
    subPath   = optional(string, null)
  }))
  default = []
}

# variable "volumes" {
#   description = <<EOT
#   The volumes for the service. This includes the name, type, and config.

#   The `name` field is the name of the volume.

#   The `type` field is the type of the volume. This can be one of the following: configMap, secret, or emptyDir.

#   The `config` field is the configuration for the volume. This can be one of the following: name, items, or sizeLimit.
#   EOT
#   type = list(object({
#     name   = string
#     type   = string
#     config = map(string)
#   }))
#   default = []
# }

variable "volumes_json" {
  description = <<EOT
  The volumes for the service in JSON format. This is useful for when you want to use a JSON string to define the volumes.
  EOT
  type        = string
  default     = "[]"
}

variable "jobs" {
  description = <<EOT
  The jobs for the service. This includes the id, before_update, after_update, and cron.

  The `id` field is the id of the job. If the field is not set, a random id will be generated. When running in a CI/CD pipeline, it's recommended to set this field to the Job ID in the pipeline so the k8s job and the job id from the pipeline match up. 
  EOT
  type = object({
    id = optional(string, null)
    before_update = optional(object({
      enabled = optional(bool, false)
      suffix  = optional(string, "-before-update")
      command = optional(list(string), null)
      args    = optional(list(string), [])
      wait    = optional(bool, true)
    }), {})
    after_update = optional(object({
      enabled = optional(bool, false)
      suffix  = optional(string, "-after-update")
      command = optional(list(string), null)
      args    = optional(list(string), [])
      wait    = optional(bool, true)
    }), {})
    cron = optional(object({
      enabled  = optional(bool, false)
      suffix   = optional(string, "")
      schedule = optional(string, "0 1 * * *")
      command  = optional(list(string), null)
      args     = optional(list(string), [])
    }), {})
  })
  default = {}
}
