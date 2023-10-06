variable "tenant_id" {
  type = string
}
variable "prefix" {
  default = "apps-"
  type = string
}
variable "eks_version" {
  type = string
  default = "1.24"
}
variable "az_list" {
  default = ["a", "b"]
  type    = list(string)
  description = "The letter at the end of the zone"
}
variable "base_ami_name" {
  default = "amazon-eks-node"
  type    = string
}
variable "capacity" {
  default = "t3.medium"
  type    = string
}
variable "instance_count" {
  default = 1
  type    = number
}
variable "min_instance_count" {
  default = 1
  type    = number
}
variable "max_instance_count" {
  default = 3
  type    = number
}
variable "os_disk_size" {
  default = 20
  type    = number
}
variable "is_ebs_optimized" {
  default = false
  type    = bool
}
variable "encrypt_disk" {
  default = false
  type    = bool
}
variable "minion_tags" {
  type = map(string)
  description = "Tags to apply to the Duplo Minions"
  default = {}
}
