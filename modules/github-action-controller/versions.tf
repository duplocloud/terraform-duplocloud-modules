terraform {
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = "~> 0.9.40"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
}
