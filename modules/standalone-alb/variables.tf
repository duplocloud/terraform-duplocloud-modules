
variable "name" {
  description = "The display name to use for the ALB"
  type = string
}

variable "tenant_id" {
  description = "The tenant object the ALB will be added to."
  type = string 
}

variable "cert_arn" {
  description = "The ARN of the certificate to use for HTTPS listeners."
  type = string
}

variable "vpc_id" {
  description = "The VPC ID to use for the ALB."
  type = string
}

variable "timeout" {
  description = "The idle timeout value, in seconds. The valid range is 1-4000 seconds. The default is 60 seconds."
  type = number
  default = 60
}

variable "health_path" {
  description = "The path to use for the health check. This is for the static response rule."
  type = string
  default = "/health"
}
