# only do plans here
run "make_an_asg" {
  command = apply
  assert {
    condition     = duplocloud_asg_profile.nodes[0].friendly_name == "fun-a"
    error_message = "friendly_name is not fun-a"
  }
}
