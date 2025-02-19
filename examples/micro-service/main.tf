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
  image = {
    uri = "nginx:latest"
  }
  port = 80
  lb = {
    enabled = false
  }
  configurations = [{
    data = {
      MESSAGE = "Hello World"
    }
  }, {
    class = "aws-secret"
    csi  = true
    managed = false
    description = "An AWS secret mounted to a pod using the CSI driver. Values are ignored by TF so users can manage them in the AWS console. Terraform only initializes the default values and required keys on creation."
    data = {
      PASSWORD = "bar"
    }
  }]
  jobs = {
    before_update = {
      enabled = true
      command = ["echo"]
      args = ["before update"]
    }
  }
}
