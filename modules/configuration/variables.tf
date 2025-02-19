variable "tenant_id" {
  description = "The tenant id."
  type        = string
}

variable "name" {
  description = "The name of the config."
  type        = string
}

variable "description" {
  description = "The description of the configuration."
  type        = string
  default     = null 
  nullable = true
}

variable "type" {
  description = "The type of the config."
  type        = string
  default     = "environment" # or files
  # make sure the value is one of the accepted values
  validation {
    condition = contains([
      "environment", "files"
    ], var.type)
    error_message = "The type must be one of the following: environment, files."
  }
}

variable "class" {
  description = "The class of the config."
  type        = string
  default     = "configmap"

  # make sure the value is one of the accepted values
  validation {
    condition = contains([
      "configmap", "secret",
      "aws-secret", "aws-ssm"
    ], var.class)
    error_message = "The class must be one of the following: configmap, secret."
  }
}

variable "csi" {
  description = "Wether to use the csi driver and bind to a kubernetes secret. Only available for aws-secret and aws-ssm."
  type        = bool
  default     = false
}

variable "managed" {
  description = "Wether terraform should manage the value of the data. If false, the data will be ignored."
  type        = bool
  default     = true
}

variable "data" {
  description = "The map of key/values for the configuration."
  type        = map(string)
  default     = {}
}

variable "value" {
  description = "The string value of the configuration. Use either data or value, not both. This will take precedence over data if it is set."
  type        = string
  default     = null 
  nullable = true
}
