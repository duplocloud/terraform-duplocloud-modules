resource "duplocloud_aws_ssm_parameter" "ssm_param" {
  for_each = var.parameters

  tenant_id = local.tenant_id
  name      = "/${var.tenant_name}/${each.key}"
  type      = coalesce(var.parameters[count.index].type, "SecureString")
  value     = each.value
}

