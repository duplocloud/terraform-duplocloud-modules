variable "tenant_name" {
  type = string
}

variable "name" {
  description = "The name of the lambda"
  type        = string
}

variable "package_type" {
  description = "The type of package to deploy"
  type        = string
}

variable "handler" {
  description = "The handler for the lambda"
  type        = string
  nullable    = true
}

variable "image" {
  type = object({
    uri               = string
    entry_point       = optional(string)
    working_directory = optional(string)
  })
}
