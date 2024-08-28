locals {
  build_name             = var.build_name
  tenant_name            = var.tenant_name
  tenant_prefix          = "duploservices-${local.tenant_name}"
  tenant_role_arn        = "arn:aws:iam::${local.account_id}:role/${local.tenant_prefix}"
  bucket_tenant          = var.bucket_tenant_name
  bucket_tenant_prefix   = "duploservices-${local.bucket_tenant}"
  bucket_tenant_role_arn = "arn:aws:iam::${local.account_id}:role/${local.bucket_tenant_prefix}"
  account_id             = data.duplocloud_aws_account.this.account_id
  tfstate_bucket         = "duplo-tfstate-${local.account_id}"
  default_region         = var.region
  region                 = var.region
  build_bucket           = var.build_bucket
}


data "duplocloud_aws_account" "this" {}

data "duplocloud_admin_aws_credentials" "this" {
}
