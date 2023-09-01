
terraform {
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = "> 0.9.40"
    }
  }
}

provider "duplocloud" {

}

data "duplocloud_tenant" "current" {
  name = "auto-02"
}

data "duplocloud_infrastructure" "current" {
  tenant_id = data.duplocloud_tenant.current.id
}

module "standalone-alb" {
  source = "../../modules/standalone-alb"
  name   = "coolest"
  tenant_id = data.duplocloud_tenant.current.id
  cert_arn = "arn:aws:acm:us-east-2:884446924812:certificate/5200e60b-6b79-4b0a-91dc-fc6f91c39dba"
  vpc_id = data.duplocloud_infrastructure.current.vpc_id
}
