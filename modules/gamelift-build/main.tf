locals {
  account_id             = data.duplocloud_aws_account.this.account_id
  tenant_prefix          = "duploservices-${var.tenant_name}"
  tenant_role_arn        = "arn:aws:iam::${local.account_id}:role/${local.tenant_prefix}"
  build_name             = "${var.tenant_name}-${var.name}-${var.build.version}"
  bucket_tenant          = var.bucket.bucket_tenant_name
  bucket_tenant_prefix   = "duploservices-${local.bucket_tenant}"
  bucket_tenant_role_arn = "arn:aws:iam::${local.account_id}:role/${local.bucket_tenant_prefix}"
  bucket_key             = coalesce(var.build.key, "${var.name}/${local.build_name}.zip")
  bucket_name            = "${local.bucket_tenant_prefix}-${var.build.bucket}-${local.account_id}"
}

data "duplocloud_aws_account" "this" {}
