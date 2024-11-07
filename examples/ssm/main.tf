terraform {
  required_version = ">= 1.4.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.19.0"
    }
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.9.40"
    }
  }
  backend "s3" {
    workspace_key_prefix = "duplocloud/components"
    key                  = "ssm"
    encrypt              = true
  }
}

variable "tenant_name" {
  description = "The name of the tenant"
  type        = string
  default     = "tf-tests"
}

provider "aws" {
  region     = data.duplocloud_tenant_aws_region.this.aws_region
  access_key = data.duplocloud_admin_aws_credentials.this.access_key_id
  secret_key = data.duplocloud_admin_aws_credentials.this.secret_access_key
  token      = data.duplocloud_admin_aws_credentials.this.session_token
}

provider "duplocloud" {

}

data "duplocloud_admin_aws_credentials" "this" {
}

data "duplocloud_tenant" "this" {
  name = var.tenant_name
}

data "duplocloud_tenant_aws_region" "this" {
  tenant_id = data.duplocloud_tenant.this.id
}

module "ssm" {
  source      = "../../modules/ssm"
  tenant_name = var.tenant_name
  parameters = [{
    name  = "foo"
    value = "bar"
  }]
}
