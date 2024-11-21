terraform {
  required_version = "~> 1.9.7"

  required_providers {
    duplocloud = {
      version = "~> 0.10.48"
      source  = "duplocloud/duplocloud"
    }
    kubernetes = { version = "~> 2.32" }
  }
}

data "duplocloud_eks_credentials" "this" { 
    count = var.cloud == "AWS" ? 1 : 0
    plan_id = var.plan_id 
    }

data "duplocloud_gke_credentials" "this" { 
    count = var.cloud == "GCP" ? 1 : 0
    plan_id = var.plan_id 
}

output "endpoint" {
  value = var.cloud == "AWS" ? data.duplocloud_eks_credentials.this[0].endpoint : var.cloud == "GCP" ? data.duplocloud_gke_credentials.this[0].endpoint : null
}

output "ca_certificate_data" {
  value = var.cloud == "AWS" ? data.duplocloud_eks_credentials.this[0].ca_certificate_data : var.cloud == "GCP" ? data.duplocloud_gke_credentials.this[0].ca_certificate_data : null
}

output "token" {
  value = var.cloud == "AWS" ? data.duplocloud_eks_credentials.this[0].token : var.cloud == "GCP" ? data.duplocloud_gke_credentials.this[0].token : null
}


variable "cloud" {
    default = "AWS"
    description = "value is either AWS or GCP"
}

variable "plan_id" {
    type = string
}
