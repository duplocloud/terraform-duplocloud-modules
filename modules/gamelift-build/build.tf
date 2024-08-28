resource "awscc_gamelift_build" "this" {
  name             = local.build_name
  version          = "1"
  operating_system = var.build_operating_system

  storage_location = {
    bucket   = local.build_bucket
    key      = var.build_bucket_key
    role_arn = local.bucket_tenant_role_arn
  }
}