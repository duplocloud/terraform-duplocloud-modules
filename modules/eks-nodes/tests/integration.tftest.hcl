# only do plans here
run "make_an_asg" {
  command = apply
  variables {
    tenant_id = "0a09ca25-7f0d-4f5f-b9fa-62290273d192"
  }
  assert {
    condition     = duplocloud_asg_profile.nodes[0].friendly_name == "apps-a"
    error_message = "friendly_name is not apps-a"
  }
}
