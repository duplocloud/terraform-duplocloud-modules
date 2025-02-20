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

variable "tenant_id" {
  type    = string
  default = "c4b717db-a61b-4edc-b895-37c3dfa58fa8"
}

module "some_config" {
  source      = "../../modules/configuration"
  tenant_id   = var.tenant_id
  name        = "db"
  prefix      = "myapp"
  description = "The connection details myapp to use the db."
  class       = "secret"
  csi         = true
  type        = "environment"
  managed     = true
  data = {
    "DB_USER" = "superadmin"
    "DB_PASS" = "supersecret"
    "DB_HOST" = "db.example.com"
    "DB_PORT" = "5432"
    "DB_NAME" = "mydb"
  }
}

output "config" {
  value = module.some_config
}
