terraform {
  required_version = ">= 1.4.4"
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.10.35"
    }
    awscc = {
      source = "hashicorp/awscc"
      version = "1.10.0"
    }
  }
}
provider "duplocloud" {
    
}

provider "awscc" {
  region     = local.region
  access_key = data.duplocloud_admin_aws_credentials.this.access_key_id
  secret_key = data.duplocloud_admin_aws_credentials.this.secret_access_key
  token      = data.duplocloud_admin_aws_credentials.this.session_token
}

