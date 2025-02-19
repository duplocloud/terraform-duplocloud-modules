resource "duplocloud_aws_ssm_parameter" "managed" {
  count     = var.managed && var.class == "aws-ssm" ? 1 : 0
  tenant_id = var.tenant_id
  name      = var.name
  type      = "SecureString"
  value     = local.data
}

resource "duplocloud_aws_ssm_parameter" "unmanaged" {
  count     = !var.managed && var.class == "aws-ssm" ? 1 : 0
  tenant_id = var.tenant_id
  name      = var.name
  type      = "SecureString"
  value     = local.data
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
