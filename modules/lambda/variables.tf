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
  validation {
    condition     = contains(["Image", "Zip"], var.package_type)
    error_message = "Allowed values for input_parameter are image and s3"
  }
}

variable "handler" {
  description = "The handler for the lambda"
  type        = string
  nullable    = true
}

variable "image" {
  type = object({
    uri               = string
    entry_point       = optional(list(string))
    working_directory = optional(string)
  })
}

variable "description" {
  type = string
  default = "Duplocloud Rocks"
}

variable "timeout"{
  description = "The timeout for the lambda"
  default = 600
  type = number
}

variable "memory_size" {
  description = "The memory size for the lambda"
  default = 2048
  type = number
}

variable "tracing_mode" {
  description = "The tracing mode for the lambda"
  default = "PassThrough"
  type = string
  validation {
    condition     = contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "Allowed values for tracing_mode are Active and PassThrough"
  }
}

variable "environment"{
  description = "The environment variables for the lambda"
  type = map(string)
  default = {}
}