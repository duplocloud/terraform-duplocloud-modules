variable "tenant_name" {
  description = "The tenant name for which to extend the IAM role"
  type        = string
}

variable "iam_policy_json" {
  description = "The IAM policy JSON which has the extra policies granted to the tenant role"
  type = string
}

variable "policy_name" {
  description = "The name for the custom IAM policy created"
  default     = "custom-policy"
  type        = string
}
