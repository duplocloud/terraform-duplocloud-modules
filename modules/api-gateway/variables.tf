variable "tenant_name" {
  type = string
}

variable "name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "type" {
  description = "The type of api gateway"
  type        = string
  default     = "http"
  validation {
    condition     = contains(["http", "rest", "socket"], var.type)
    error_message = "Allowed values for input_parameter are http, rest, socket"
  }
}

variable "body" {
  description = "The body of the api gateway as a string"
  type        = string
  nullable    = true
  default     = null
}

variable "openapi_file" {
  description = "Filepath to the open api file. Use interchangeably with providing the string in 'body'"
  type        = string
  nullable    = true
  default     = null
}

variable "openapi_variables" {
  description = "Extra parameters required for the open api template file that are not account id, duplo tenant, the domain, or the aws region"
  type        = map(any)
  default     = {}
}

# variable "enable_logging" {
#   description = "Enable logging for the gateway"
#   type        = bool
#   default     = true
# }

variable "enable_private_link" {
  description = "Enable private link for the gateway"
  type        = bool
  default     = false
}

variable "cert_name" {
  description = "The name of the certificate"
  type        = string
}

variable "vpc_link_targets" {
  description = "The list of vpc link targets when type is not http, ie rest, private-rest, or socket"
  type        = list(string)
  default     = []
}

variable "subdomain" {
  description = "The subdomain as the prefix on the base domain"
  type        = string
  nullable    = true
  default     = null
}
