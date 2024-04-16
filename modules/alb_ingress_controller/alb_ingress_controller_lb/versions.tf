terraform {
  required_version = ">= 1.3.8"
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.10.12"
    }
  }
}
