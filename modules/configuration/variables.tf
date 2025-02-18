variable "tenant_id" {
  description = "The tenant id."
  type        = string
}

variable "name" {
  description = "The name of the config."
  type        = string
}

variable "data" {
  description = "Environment variables."
  type = map(string)
}
