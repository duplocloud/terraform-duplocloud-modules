# only do plans here
run "validate_name" {
  command = plan
  variables {
    tenant_id = "644636a2-d604-4b77-aaae-8c07acce7c96"
  }
  assert {
    condition     = duplocloud_asg_profile.nodes[0].friendly_name == "apps-a-${local.ami_identifier}"
    error_message = "friendly_name is not apps-a-${local.ami_identifier}"
  }
}
