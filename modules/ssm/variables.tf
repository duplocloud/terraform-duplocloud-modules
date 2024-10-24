variable "tenant_name" {
  type = string
}
variable "parameters" {
  type = list(object({
    key  = string
    type  = optional(string, "SecureString")
    value = string
  }))
}