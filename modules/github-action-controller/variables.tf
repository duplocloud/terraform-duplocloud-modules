variable "tenant_name" {
  description = "The name of the tenant"
  type = string
}

variable "version" {
  description = "The version of the Github Actions Controller Helm chart to install"
  type = string
  default = "0.23.3"
}

variable "values" {
  description = "Additional values to pass to the Github Actions Controller Helm chart"
  type = map
  default = {}
}
