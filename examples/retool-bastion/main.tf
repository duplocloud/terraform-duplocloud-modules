terraform {
  required_version = ">= 1.4.4"
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.9.40"
    }
  }
  backend "s3" {
    workspace_key_prefix = "duplocloud/components"
    key                  = "retool-bastion"
    encrypt              = true
  }
}

provider "duplocloud" {

}

data "duplocloud_tenant" "current" {
  name = "tf-tests"
}

module "retool_bastion" {
  source            = "../../modules/retool-bastion"
  tenant_id         = data.duplocloud_tenant.current.id
  retool_public_key = "abc123"
}

output "info" {
  value = module.retool_bastion
}
