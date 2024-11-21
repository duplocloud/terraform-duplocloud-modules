variable "tenant_name"{
  type = string
}

variable "tenant_id"{
  type = string
}

variable "ports" {
  type = list(string)
  default = ["1-65535"]
}

variable "vpc_cidr" {
  type = list(string)
  default = []
}