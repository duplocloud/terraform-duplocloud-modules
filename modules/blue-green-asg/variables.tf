
variable "tenant_id" {}
variable "tenant_name" {}
variable "az_count"{ default = 2}
variable "metadata" {
  type = map(object({
    key   = string
    value = string
  }))
}

variable "minion_tags" {
  type = map(object({
    key   = string
    value = string
  }))
}

variable "blue_flag" {
  description = "Flag to enable blue ASG"
  type        = bool
  default     = true
}

variable "green_flag" {
    description = "Flag to enable green ASG"
    type        = bool
    default     = true
}

variable "blue_asg_instance_count" {
  description = "Number of instances in blue ASG"
  type        = number
}

variable "green_asg_instance_count" {
  description = "Number of instances in green ASG"
  type        = number
}

variable "blue_asg_min_instance_count" {
  description = "Minimum number of instances in blue ASG"
  type        = number
}

variable "green_asg_min_instance_count" {
  description = "Minimum number of instances in green ASG"
  type        = number
}

variable "blue_asg_max_instance_count" {
  description = "Maximum number of instances in blue ASG"
  type        = number
}
variable "green_asg_max_instance_count" {
  description = "Maximum number of instances in green ASG"
  type        = number
}

variable "blue_asg_capacity" {
  description = "Capacity of blue ASG"
  type        = number
}

variable "green_asg_capacity" {
  description = "Capacity of green ASG"
  type        = number
}

variable "blue_image_id" {
  description = "AMI ID for blue ASG"
  type        = string
}

variable "green_image_id" {
  description = "AMI ID for green ASG"
  type        = string
}

variable "custom_user_data_addition_blue" {
  description = "Custom user data addition for blue ASG"
  type        = string
}

variable "custom_user_data_addition_green" {
  description = "Custom user data addition for green ASG"
  type        = string
}

variable "blue_asg_min_instance_count" {
    description = "Minimum number of instances in blue ASG"
    type        = number
}

variable "green_asg_min_instance_count" {
    description = "Minimum number of instances in green ASG"
    type        = number
}

variable "blue_asg_max_instance_count" {
    description = "Maximum number of instances in blue ASG"
    type        = number
}

variable "green_asg_max_instance_count" {
    description = "Maximum number of instances in green ASG"
    type        = number
}