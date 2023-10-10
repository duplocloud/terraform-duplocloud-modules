
data "duplocloud_tenant" "current" {
  name = "tf-tests"
}

run "validate_name" {
  command = plan
  variables {
    tenant_id = data.duplocloud_tenant.current.id
  }
  assert {
    condition     = duplocloud_asg_profile.nodes[0].friendly_name == "apps-a"
    error_message = "friendly_name is not apps-a"
  }
}
