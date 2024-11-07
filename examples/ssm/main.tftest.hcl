# only do plans here
run "make_an_asg" {
  command = apply
  assert {
    condition     = length(regexall("fun-a", module.asg.nodes[0].friendly_name)) > 0
    error_message = "friendly_name does not contain fun-a"
  }
}
