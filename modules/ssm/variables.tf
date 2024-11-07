variable "tenant_name" {
  type = string
}
variable "parameters" {
  type = list(object({
    name  = string
    type  = optional(string, "SecureString")
    value = string
  }))
  default = []
}
