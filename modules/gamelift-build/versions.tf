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


