provider "duplocloud" {}

provider "google" {
  project     = data.duplocloud_infrastructure.this.account_id
  region      = data.duplocloud_infrastructure.this.region
}