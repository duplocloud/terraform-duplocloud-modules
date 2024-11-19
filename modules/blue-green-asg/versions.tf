terraform {
  required_version = ">= 1.2.4"
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.10.18"
    }
  }
}
