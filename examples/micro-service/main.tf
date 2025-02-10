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
    key                  = "micro-service"
    encrypt              = true
  }
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
  image = {
    uri = "nginx:latest"
  }
  port = 80
  lb = {
    enabled = true
  }
}
