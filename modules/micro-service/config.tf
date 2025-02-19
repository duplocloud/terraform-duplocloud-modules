module "configurations" {
  for_each    = { for idx, config in local.configurations : idx => config }
  source      = "../configuration"
  name        = each.value.name
  type        = each.value.type
  description = each.value.description
  tenant_id   = local.tenant.id
  class       = each.value.class
  data        = each.value.data
  value       = each.value.value
  csi         = each.value.csi
  managed     = each.value.managed
}
