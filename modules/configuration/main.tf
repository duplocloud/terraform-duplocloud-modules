locals {
  data = var.value != null ? var.value : jsonencode(var.data)
  # get just the keys from the data map
  keys = keys(var.data)
  annotations = {
    "kubernetes.io/description" = var.description
  }
  # tags = [{
  #   key   = "managed-by"
  #   value = "tf"
  # },{
  #   key = "description"
  #   value = var.description
  # }]
}


