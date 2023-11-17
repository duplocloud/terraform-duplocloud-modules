locals {
  minion_tags = [
    for k, v in var.minion_tags : {
      key   = k
      value = v
    }
  ]
  metadata = [
    for k, v in var.metadata : {
      key   = k
      value = v
    }
  ]
}

data "duplocloud_native_host_image" "this" {
  tenant_id     = var.tenant_id
  is_kubernetes = true
}

data "duplocloud_infrastructure" "this" {
  tenant_id = var.tenant_id
}

data "duplocloud_plan" "this" {
  # DuploCloud plan names always match the infrastructure they're associated with.
  plan_id = data.duplocloud_infrastructure.this.infra_name
}

resource "duplocloud_asg_profile" "nodes" {
  for_each = toset(data.duplocloud_plan.this.availability_zones)

  zone          = index(data.duplocloud_plan.this.availability_zones, each.key)
  friendly_name = join("-", compact([var.prefix, each.key]))
  image_id      = data.duplocloud_native_host_image.this.image_id

  tenant_id          = var.tenant_id
  instance_count     = var.instance_count_per_zone
  min_instance_count = var.min_instance_count_per_zone
  max_instance_count = var.max_instance_count_per_zone
  capacity           = var.capacity
  is_ebs_optimized   = var.is_ebs_optimized
  encrypt_disk       = true

  # these stay the same for autoscaling eks nodes
  agent_platform        = 7
  is_minion             = true
  allocated_public_ip   = false
  cloud                 = 0
  use_launch_template   = true
  is_cluster_autoscaled = true

  metadata {
    key   = "OsDiskSize"
    value = tostring(var.os_disk_size)
  }
  dynamic "metadata" {
    for_each = local.metadata
    content {
      key   = metadata.value.key
      value = metadata.value.value
    }
  }
  dynamic "minion_tags" {
    for_each = local.minion_tags
    content {
      key   = minion_tags.value.key
      value = minion_tags.value.value
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
