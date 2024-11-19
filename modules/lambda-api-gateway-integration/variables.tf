variable "service_name" {
  description = "The name of the service"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "serverless_common_config" {
  description = "The serverless common configuration"
  type = object({
    function_runtime                 = string
    function_source_code_bucket_name = string
    api_gateway_id                   = optional(string)
    api_key_required                 = optional(bool)
    environment_variables            = optional(map(string))
    ssm_to_fetch                     = optional(map(string))
  })
}

variable "functions" {
  description = "A map of Lambda functions and their configurations"
  type = list(object({
    name                            = string
    handler                         = string
    function_runtime                = optional(string)
    timeout                         = optional(number, 6)
    memory_size                     = optional(number, 1024)
    ephemeral_storage_size          = optional(string)
    function_source_code_bucket_key = string
    schedule = optional(object({
      rate    = string,
      enabled = bool
      input   = optional(string)
    }))
    event_bridge = optional(object({
      event_bus_arn = string,
      pattern = list(object({
        source      = list(string),
        detail_type = optional(list(string)),
        detail      = optional(any)
      }))
    }))
    events = optional(list(object({
      path             = string
      method           = string
      cors             = bool
      content_handling = optional(string)
      timeout          = optional(number)
      authorizer = optional(object({
        id   = string
        type = optional(string)
      }))
    })))
    environment_variables = optional(map(string))
    warmup_enabled        = optional(bool, false)
    es_logging_enabled    = optional(bool, false)
  }))
}

variable "tenant_name" {
  description = "The name of the duplo tenant"
  type        = string
}

variable "api_endpoint_type" {
  description = "API endpoint type."
  type        = string
  default     = "EDGE"
}

variable "enable_warmup_lambda" {
  type    = bool
  default = false
}

variable "es_logging_environments" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}

variable "es_cwl_destination_arn" {
  type    = string
  default = "arn:aws:lambda:us-east-1:366133256645:function:cwl-opensearch"
}
