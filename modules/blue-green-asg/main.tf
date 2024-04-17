

# Find the EKS AMIs for this tenant
data "duplocloud_native_host_image" "eks-worker" {
  tenant_id     = var.tenant_id
  is_kubernetes = true
}

# Create plain EKS nodes for most workloads.
resource "duplocloud_asg_profile" "hosts-eks_zone_blue" {
  count = var.blue_flag ? var.az_count : 0

  tenant_id             = var.tenant_id
  friendly_name         = "eks-zone-${count.index + 1}-blue"
  instance_count        = var.blue_asg_instance_count ? var.blue_asg_instance_count : var.green_asg_instance_count
  min_instance_count    = var.blue_asg_min_instance_count ? var.blue_asg_min_instance_count : var.green_asg_min_instance_count
  max_instance_count    = var.blue_asg_max_instance_count ? var.blue_asg_max_instance_count : var.green_asg_max_instance_count
  image_id              = var.blue_image_id ? var.blue_image_id : data.duplocloud_native_host_image.eks-worker.image_id
  is_cluster_autoscaled = true
  capacity              = var.blue_asg_capacity ? var.blue_asg_capacity : var.green_asg_capacity
  agent_platform        = 7           # EKS
  zone                  = count.index
  user_account          = var.tenant_name
  prepend_user_data     = true # always true - it is ok to have blank user data
  base64_user_data      = base64encode(var.custom_user_data_addition_blue)
  
  dynamic "metadata" {
    for_each = var.metadata
    content {
      key   = metadata.value.key
      value = metadata.value.value
    }
  }
  dynamic "minion_tags" {
    for_each = var.minion_tags
    content {
      key   = minion_tags.value.key
      value = minion_tags.value.value
    }
  }
  lifecycle {
    create_before_destroy = true
  }

}

resource "duplocloud_asg_profile" "hosts-eks_green" {

  count = var.green_flag ? var.az_count : 0

  tenant_id             = var.tenant_id
  friendly_name         = "eks-zone-${count.index + 1}-green"
  instance_count        = var.green_asg_instance_count ? var.green_asg_instance_count : var.blue_asg_instance_count
  min_instance_count    = var.green_asg_min_instance_count ? var.green_asg_min_instance_count : var.blue_asg_min_instance_count
  max_instance_count    = var.green_asg_max_instance_count ? var.green_asg_max_instance_count : var.blue_asg_max_instance_count
  image_id              = var.green_image_id ?  var.green_image_id : data.duplocloud_native_host_image.eks-worker.image_id

  is_cluster_autoscaled = true
  capacity              = var.green_asg_capacity ? var.green_asg_capacity : var.blue_asg_capacity
  agent_platform        = 7           # EKS
  zone                  = count.index
  user_account          = var.tenant_name
  prepend_user_data     = true
  base64_user_data      = base64encode(var.custom_user_data_addition_green)

  dynamic "metadata" {
    for_each = var.metadata
    content {
      key   = metadata.value.key
      value = metadata.value.value
    }
  }
  dynamic "minion_tags" {
    for_each = var.minion_tags
    content {
      key   = minion_tags.value.key
      value = minion_tags.value.value
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
