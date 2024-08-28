resource "awscc_gamelift_build" "this" {
  name             = local.build_name
  version          = "1"
  operating_system = var.build.operating_system

  storage_location = {
    bucket   = local.bucket_name
    key      = local.bucket_key
    role_arn = local.bucket_tenant_role_arn
  }
}
