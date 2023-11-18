variable "tenant_id" {
  type = string
}
variable "prefix" {
  default = "eks"
  type    = string
}
variable "capacity" {
  description = "Instance type."
  type        = string
}
variable "instance_count_per_zone" {
  description = "Desired number of instances in each zone's ASG."
  type        = number
}
variable "min_instance_count_per_zone" {
  description = "Minimum number of instances in each zone's ASG."
  type        = number
}
variable "max_instance_count_per_zone" {
  description = "Maximum number of instances in each zone's ASG."
  type        = number
}
variable "os_disk_size" {
  default = 20
  type    = number
}
variable "is_ebs_optimized" {
  default = false
  type    = bool
}
variable "minion_tags" {
  type        = map(string)
  description = "Tags to apply to the Duplo Minions"
  default     = {}
}
variable "metadata" {
  type        = map(string)
  description = "Metadata to apply to the Duplo Minions"
  default     = {}
}
