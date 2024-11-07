resource "duplocloud_aws_ssm_parameter" "ssm_param" {
  count = length(var.parameters)

  tenant_id = local.tenant_id
  name      = "/${var.tenant_name}/${var.parameters[count.index].name}"
  type      = coalesce(var.parameters[count.index].type, "SecureString")
  value     = var.parameters[count.index].value
}

