variable "region" { default = "" }

variable "tenant_id" {
  description = "The id of the tenant"
  type        = string
}

variable "s3_buckets" {
  description = "A map of S3 buckets with their configurations"
  type = map(object({
    allow-public = optional(bool)
    public       = optional(bool)
    cors         = optional(bool)
  }))
}

variable "partition" {
  description = "The partition of the AWS"
  type        = string
}

variable "aws_account_id" {
  description = "The id of the AWS account"
  type        = string
}
