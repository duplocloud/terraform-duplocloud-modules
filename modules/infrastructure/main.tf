locals {

}

resource "duplocloud_infrastructure" "current" {
  infra_name        = var.name
  cloud             = 0 // AWS
  region            = var.region
  azcount           = 2
  enable_k8_cluster = true
  address_prefix    = var.cidr_base
  subnet_cidr       = 22
}

resource "duplocloud_infrastructure_setting" "settings" {
  infra_name = duplocloud_infrastructure.current.infra_name

  setting {
    key   = "EnableClusterAutoscaler"
    value = "true"
  }

  setting {
    key   = "K8sVersion"
    value = var.eks_version
  }
}