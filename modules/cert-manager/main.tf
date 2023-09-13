locals {
  namespace = "duploservices-${var.tenant_name}"
  values = yamldecode(templatefile("${path.module}/values.yaml", {
    namespace = local.namespace
  }))
}

resource "helm_release" "cert_manager" {
  name        = "cert-manager"
  repository  = "https://charts.jetstack.io"
  chart       = "cert-manager"
  version     = var.version
  namespace   = local.namespace
  values = [
    yamlencode(var.values),
    yamlencode(local.values),
  ]
  set {
    name  = "nodeSelector.tenantname"
    value = "duploservices-dev01"
  }
}
