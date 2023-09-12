variable "tenant_name" {
  description = "The name of the tenant"
  type = string
}

variable "version" {
  description = "The version of the Cert Manager Helm chart to install"
  type = string
  default = "v1.11.1"
}

variable "values" {
  description = "Additional values to pass to the Cert Manager Helm chart"
  type = map
  default = {}
}
