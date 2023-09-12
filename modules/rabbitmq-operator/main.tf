locals {
  namespace = "duploservices-${var.tenant_name}"
  values = yamldecode(templatefile("${path.module}/values.yaml", {
    namespace = local.namespace
  }))
}

resource "helm_release" "rabbitmq-operator" {
  name        = "rabbitmq-operator"
  repository  = "oci://registry-1.docker.io/bitnamicharts"
  chart       = "rabbitmq-cluster-operator"
  version     = var.version
  namespace   = local.namespace
  values = [
    yamlencode(local.values),
    yamlencode(var.values)
  ]
}
