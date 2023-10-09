variable "tenant_id" {
  type = string
}

variable "name" {
  type = string
}

variable "image" {
  type = string
}

variable "replicas" {
  type = number
  default = 1
}

variable "env" {
  type = map(string)
  default = {}
}

variable "env_secrets" {
  type = list(string)
  default = []
}

variable "lb_config" {
  type = object({
    priority = optional(number, 0)
    path_pattern = string
    health_check_url = string
    listener_arn = string
    port = number
  })
}

variable "pod_config" {
  type = object({
    Annotations = optional(map(string))
    Labels = optional(map(string))
    RestartPolicy = optional(string)
    PodSecurityContext = optional(any)
    Volumes = optional(list(any))
    DeploymentStrategy = optional(any)
  })
  default = {}
}

variable "container_config" {
  type = object({
    Resources = optional(object({
      limits = optional(map(string))
      requests = optional(map(string))
    }))
  })
  default = {}
}
