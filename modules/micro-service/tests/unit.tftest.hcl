# only do plans here
run "validate_defaults" {
  command = plan
  variables {
    tenant = "dev01"
    name   = "myapp"
    image = {
      uri = "nginx:latest"
    }
  }
  # check that htew output for config_name is the same as the name
  assert {
    condition     = duplocloud_duplo_service.this.docker_image == "nginx:latest"
    error_message = "The image was not set on the service correctly."
  }
}
