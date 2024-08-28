variable "tenant_name" {
  description = "The tenant this build will be deployed into"
  type = string
}

variable "build_version" {
  description = "The version of the build"
  type = string
  default = "0.3.0"
}

variable "build_operating_system" {
  description = "The operating system of the build"
  type = string
  default = "AMAZON_LINUX_2"
  
}

variable "build_bucket" {
  description = "The bucket where the build is stored"
  type = string
}

variable "build_bucket_key" { 
  description = "The key of the build in the bucket"
  type = string
}

variable "fleet_compute_type" {
  description = "The type of compute to use for the fleet"
  type = string
  default = "EC2"
}

variable "fleet_ec2_instance_type" {
  description = "The type of EC2 instance to use for the fleet"
  type = string
  default = "c4.large"
}

variable "fleet_ec2_inbound_permissions" {
  description = "The inbound permissions for the fleet"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr = string
  }))
}

variable "fleet_type" {
  description = "The type of fleet"
  type = string
  default = "ON_DEMAND"
}

variable "fleet_new_game_session_protection_policy" {
  description = "The new game session protection policy for the fleet"
  type = string
  default = "FullProtection"
}

variable "fleet_locations" {
  description = "The locations for the fleet"
  type = list(object({
    location = string
    priority = number
  }))

}
variable "fleet_launch_path" {
  description = "The launch path for the fleet"
  type = string
}

variable "fleet_parameters" {
  description = "The parameters for the fleet"
  type = string
}

variable "build_name" {
  description = "The name of the build"
  type = string
}
variable "tenant_name" {
  description = "The tenant this build will be deployed into"
  type = string
}
variable bucket_tenant_name {
  description = "The name of the tenant the build bucket is in"
}

variable "region" {
  description = "The region to deploy the build into"
  type = string
}