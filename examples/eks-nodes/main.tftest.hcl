# only do plans here
run "make_an_asg" {
  command = apply
  assert {
    condition     = length(regexall("fun-a", duplocloud_asg_profile.nodes[0].friendly_name)) > 0
    error_message = "friendly_name does not contain fun-a"
  }
}
