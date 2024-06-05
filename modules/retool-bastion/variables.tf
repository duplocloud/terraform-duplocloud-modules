variable "tenant_id" {
  type = string
}

variable "name" {
  description = "The name of the instance"
  type        = string
  default     = "retool-bastion"
}

variable "capacity" {
  description = "The size of the instance"
  type        = string
  default     = "t3.small"
}

variable "retool_public_key" {
  description = "The public key for the retool user"
  type        = string
}
