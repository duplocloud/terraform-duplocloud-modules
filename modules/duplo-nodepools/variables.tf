# Create plain EKS nodes for most workloads.
variable "tenant_name" {
  description = "The name of the tenant"
  type        = string
}

variable "plan_id" {
  description = "The plan ID"
  type        = string
}

variable "node_pool_name" {
  description = "The name of the node pool"
  type        = string
}

variable "auto_repair" {
  description = "Whether auto repair is enabled"
  type        = bool
  default = true
}

variable "auto_upgrade"{
  description = "Whether auto upgrade is enabled"
  type        = bool
  default = true
}

variable "is_autoscaling_enabled" {
  description = "Whether autoscaling is enabled"
  type        = bool
  default = true
}

variable "zones" {
  description = "The zones in which the node pool will be created"
  type        = list(string)
  default = ["us-east1-b"]
}

variable "location_policy" {
  description = "Update strategy of the node pool"
  default = "BALANCED"
}


variable "image_type" {
  description = "The image type of the node pool"
  type        = string
  default = "cos_containerd"
}

variable "machine_type"{
  description = "The machine type of the node pool"
  type        = string
  default     = "e2-standard-4"
}

variable "disc_type" {
  description = "The disk type of the node pool"
  type        = string
  default     = "pd-standard"
}

variable "disc_size_gb" {default=100}

variable "initial_node_count" {default=1}
variable "labels" {
  description = "The map of Kubernetes labels (key/value pairs) to be applied to each node."
  type        = map(string)
  default = null
}
variable "min_node_count" {default=1}
variable "max_node_count" {default = 10}
variable "metadata" {
  description = "The metadata key/value pairs assigned to instances in the cluster."
    type        = map(string)
  default = null
}
variable "resource_labels" {
  description = " Resource labels associated to node pool"
  type        = map(string)
  default = null

}

variable "spot" {
  description = "Whether to use spot instances"
  type        = bool
  default     = false
}

variable "tags" {
  description = "The list of instance tags applied to all nodes. Tags are used to identify valid sources or targets for network firewalls and are specified by the client during cluster or node pool creation. Each tag within the list must comply with RFC1035."
  type        = list(string)
  default     = null 
}

variable "taints" {
  description = "The list of Kubernetes taints to be applied to each node."
  type        = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = null
}

variable "timeouts" {
  description = "The timeouts configuration"
  type        = object({
    create = string
    update = string
    delete = string
  })
  default = null
}

variable "total_max_node_count" {
  description = "Maximum number of nodes for one location in the NodePool. Must be >= minNodeCount."
  default = 10

}
variable "total_min_node_count" {
  description = "Minimum number of nodes for one location in the NodePool. Must be <= maxNodeCount."
  default = 1
}

variable "upgrade_settings" {
  description = "The upgrade settings"
  default = null
  type        = object({
    maxSurge       = string
    maxUnavailable = string
    strategy = string
  })
}
