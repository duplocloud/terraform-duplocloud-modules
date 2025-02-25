# only do plans here
run "files_with_no_csi" {
  command = plan
  variables {
    tenant_id = "2cf9a5bd-311c-47d3-93be-df812e98e775"
    name      = "conf"
    prefix    = "myapp"
    managed   = false
    csi       = false
    type      = "files"
    class     = "aws-secret"
  }
  # the volume output should be null with this configuration
  assert {
    condition     = output.volume == null
    error_message = "The volume output should be null with this configuration."
  }
}
run "files_with_csi_environment" {
  command = plan
  variables {
    tenant_id = "2cf9a5bd-311c-47d3-93be-df812e98e775"
    name      = "conf"
    prefix    = "myapp"
    csi       = true
    type      = "environment"
    class     = "aws-secret"
  }
  # the volume output should be null with this configuration
  assert {
    condition     = output.volume != null
    error_message = "The volume output should be null with this configuration."
  }
}
