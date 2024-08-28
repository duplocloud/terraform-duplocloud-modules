variable "tenant_name" {
  description = "The tenant this build will be deployed into"
  type        = string
}

variable "name" {
  description = "The name of the application. The build name will be this name with the version appended"
  type        = string
}

variable "build" {
  description = "The build to deploy"
  type = object({
    version            = string
    bucket             = string
    operating_system   = optional(string, "AMAZON_LINUX_2")
    bucket_tenant_name = optional(string, "devops")
    bucket_key         = optional(string)
  })
}

variable "fleet" {
  description = "The fleet to deploy the build to"
  type = object({
    type                               = optional(string, "ON_DEMAND")
    new_game_session_protection_policy = optional(string, "FullProtection")
    launch_path                        = optional(string)
    parameters                         = optional(string)
    compute_type                       = optional(string, "EC2")
    ec2_instance_type                  = optional(string, "c4.large")
    ec2_inbound_permissions = optional(list(object({
      from_port = number
      to_port   = number
      protocol  = string
      ip_range  = string
    })))
    locations = optional(list(object({
      location = string
      priority = number
    })))
  })
}
