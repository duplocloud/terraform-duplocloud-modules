variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "cidr_base" {
  type = string
  default = "10.221.0.0/16"
}

variable "eks_version" {
  type    = string
  default = "1.24"
}