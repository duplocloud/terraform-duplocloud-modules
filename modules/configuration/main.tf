locals {
  data = var.value != null ? var.value : jsonencode(var.data)
}


