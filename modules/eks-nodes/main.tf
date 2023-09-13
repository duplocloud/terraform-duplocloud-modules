locals {
  minion_tags = [
    for k, v in var.minion_tags : {
      key   = k
      value = v
    }
  ]
}

data "aws_ami" "eks" {
  most_recent      = true
  owners           = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_version}-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "duplocloud_asg_profile" "nodes" {
  count                 = length(var.az_list)
  zone                  = count.index
  friendly_name         = "${var.prefix}${var.az_list[count.index]}"
  image_id              = data.aws_ami.eks.id

  tenant_id             = var.tenant_id
  instance_count        = var.instance_count
  min_instance_count    = var.min_instance_count
  max_instance_count    = var.max_instance_count
  capacity              = var.capacity
  is_ebs_optimized      = var.is_ebs_optimized
  encrypt_disk          = var.encrypt_disk

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
  dynamic "minion_tags" {
    for_each = local.asg_minion_tags
    content {
      key   = minion_tags.value.key
      value = minion_tags.value.value
    }
  }
}
