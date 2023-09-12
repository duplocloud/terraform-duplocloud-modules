variable "tenant_name" {
  description = "The name of the tenant"
  type = string
}

variable "version" {
  description = "The version of the RabbitMQ Operator Helm chart to install"
  type = string
  default = "3.7.1"
}

variable "values" {
  description = "Additional values to pass to the RabbitMQ Operator Helm chart"
  type = map
  default = {}
}
