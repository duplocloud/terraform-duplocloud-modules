data "duplocloud_infrastructure" "this" {
    tenant_id = var.tenant_id
}

locals {
    source_tenant_prefixes      = [for tenant in var.source_tenants : "duploinfra-${tenant}"]
    destination_tenant_name = var.tenant_name
    destination_tenant_prefix   = "duploservices-${local.destination_tenant_name}"
    network_name  = "duploinfra-${data.duplocloud_infrastructure.this.infra_name}"
    project_id = data.duplocloud_infrastructure.this.account_id
}

resource "random_string" "tenant-hash" {
  length           = 4
  min_lower = 4
}

resource "google_compute_firewall" "rules" {
  project     = local.project_id
  name        = "${local.destination_tenant_prefix}-additional=rules-${random_string.tenant-hash.result}"
  network     = local.network_name
  description = "Creates firewall rule allowing traffic between tenant tags"

  allow {
    protocol  = "tcp"
    ports     = var.ports
  }

  source_tags = local.source_tenant_prefixes
  target_tags = [local.destination_tenant_prefix]
}