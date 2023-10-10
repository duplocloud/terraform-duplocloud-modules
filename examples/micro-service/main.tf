terraform {
  required_version = ">= 1.4.4"
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = "> 0.9.40"
    }
  }
}
provider "duplocloud" {}

data "duplocloud_tenant" "current" {
  name = "tf-tests"
}

module "some_service" {
  source    = "../../modules/micro-service"
  tenant_id = data.duplocloud_tenant.current.id
  name      = "some-service"
  image     = "nginx:latest"
  lb_config = {
    health_check_url = "/"
    listener_arn     = "somearn"
    path_pattern     = "/*"
    port             = 80
    priority         = 1
  }
}
