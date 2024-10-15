locals {
  ami_identifier = random_integer.identifier.result
  asg_ami        = var.asg_ami != null ? var.asg_ami : data.aws_ami.eks.id
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

# discover the ami
data "aws_ami" "eks" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["${var.base_ami_name}-${var.eks_version}-*"]
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
  count         = length(var.az_list)
  zone          = count.index
  friendly_name = "${var.prefix}${var.az_list[count.index]}-${local.ami_identifier}"
  image_id      = local.asg_ami

  tenant_id           = var.tenant_id
  instance_count      = var.instance_count
  min_instance_count  = var.min_instance_count
  max_instance_count  = var.max_instance_count
  capacity            = var.capacity
  is_ebs_optimized    = var.is_ebs_optimized
  encrypt_disk        = var.encrypt_disk
  use_spot_instances  = var.use_spot_instances
  max_spot_price      = var.max_spot_price
  can_scale_from_zero = var.can_scale_from_zero

  # these stay the same for autoscaling eks nodes
  agent_platform      = 7
  is_minion           = true
  allocated_public_ip = false
  cloud               = 0
  # use_launch_template = true
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
    ignore_changes        = [instance_count]
  }
}

resource "random_integer" "identifier" {
  min = 10000
  max = 99999
  keepers = {
    asg_ami             = local.asg_ami
    capacity            = var.capacity
    is_ebs_optimized    = var.is_ebs_optimized
    encrypt_disk        = var.encrypt_disk
    use_spot_instances  = tostring(var.use_spot_instances)
    max_spot_price      = tostring(var.max_spot_price)
    can_scale_from_zero = var.can_scale_from_zero
    prefix              = var.prefix
  }
}

resource "null_resource" "destroy_script" {
  count = var.pod_rollover ? length(var.az_list) : 0
  triggers = {
    fullname = duplocloud_asg_profile.nodes[count.index].fullname
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/kubectl-1.sh ${self.triggers.fullname} ${terraform.workspace} ${count.index}"
  }
}

resource "null_resource" "create_script" {
  count = var.pod_rollover ? length(var.az_list) : 0
  triggers = {
    fullname = duplocloud_asg_profile.nodes[count.index].fullname
  }

  provisioner "local-exec" {
    when       = create
    command    = "${path.module}/kubectl.sh ${count.index} ${terraform.workspace} ${var.rollover_timeout}"
    on_failure = continue
  }
}