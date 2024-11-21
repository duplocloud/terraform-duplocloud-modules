# Create plain EKS nodes for most workloads.
data "duplocloud_tenant" "this" {
  name = var.tenant_name
}


resource "duplocloud_gcp_node_pool" "node_pool" {
  tenant_id              = data.duplocloud_tenant.this.id
  name                   = var.node_pool_name
  
  auto_repair = var.auto_repair
  is_autoscaling_enabled = var.is_autoscaling_enabled
  zones           = var.zones
  location_policy = var.location_policy
  auto_upgrade    = var.auto_upgrade
  image_type      = var.image_type
  machine_type    = var.machine_type
  disc_type       = var.disc_type
  disc_size_gb    = var.disc_size_gb
  initial_node_count = var.initial_node_count
  labels = var.labels
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count
  metadata = var.metadata
  resource_labels = var.resource_labels
  spot = var.spot
  # tags = var.tags
  # taints = var.taints
  # timeouts = var.timeouts
  total_max_node_count = var.total_max_node_count
  total_min_node_count = var.total_min_node_count
  # upgrade_settings = var.upgrade_settings 
}