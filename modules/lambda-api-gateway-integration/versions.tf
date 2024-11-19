terraform {
  required_version = ">= 1.4.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.12.0"
    }
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.10.24"
    }
  }
}