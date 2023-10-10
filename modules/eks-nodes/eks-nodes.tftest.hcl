run "validate_name" {
  command = plan
  variables {
    tenant_id = "dad12b90-b1ee-43fc-8b13-eef2bb7a0fcf"
  }
  assert {
    condition     = duplocloud_asg_profile.nodes[0].friendly_name == "apps-a"
    error_message = "friendly_name is not apps-a"
  }
}
