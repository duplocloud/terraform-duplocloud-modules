terraform {
  required_version = ">= 1.4.4"
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.9.40"
    }
  }
  # backend "s3" {
  #   workspace_key_prefix = "duplocloud/components"
  #   key                  = "micro-service"
  #   encrypt              = true
  # }
}
provider "duplocloud" {}

variable "tenant" {
  type    = string
  default = "tf-tests"
}

module "some_service" {
  source = "../../modules/micro-service"
  tenant = var.tenant
  name   = "some-service"
  command = ["echo"]
  image = {
    uri = "nginx:latest"
  }
  port = 80
  lb = {
    enabled = true
  }
  jobs = {
    before_update = {
      enabled = true
      args = ["before update"]
    }
  }
}

output "service" {
  value = module.some_service.before_update.spec[0].template[0].spec[0].container[0]
}
