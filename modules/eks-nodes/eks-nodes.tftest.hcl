
run "validate_name" {
  command = plan
  assert {
    condition     = duplocloud_asg_profile.nodes[0].friendly_name == "apps-a"
    error_message = "friendly_name is not apps-a"
  }
}
