terraform {
  required_version = ">= 1.4.4"
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.10.0"
    }
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.10.0"
    }
  }
  backend "s3" {
    workspace_key_prefix = "duplocloud/components"
    key                  = "gamelift-build"
    encrypt              = true
  }
}

variable "tenant_name" {
  description = "The name of the tenant"
  type        = string
  default     = "tf-tests"
}

provider "awscc" {
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

module "gamelift-build" {
  source      = "../../modules/gamelift-build"
  tenant_name = var.tenant_name
  name        = "arcade"
  build = {
    version = "1"
    bucket  = "somebucket"
  }
  fleet = {
    launch_path       = "/local/game/mygame/Binaries/Linux/MyGame"
    parameters        = "--special-sauce"
    ec2_instance_type = "c5.xlarge"
    ec2_inbound_permissions = [{
      from_port = 7777
      to_port   = 7777
      ip_range  = "0.0.0.0/0"
      protocol  = "UDP"
    }]
  }
}
