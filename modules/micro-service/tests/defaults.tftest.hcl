# only do plans here
run "validate_defaults" {
  command = plan
  variables {
    tenant = "dev01"
    name   = "myapp"
  }
  # check that the image uri is defaulted correctly
  assert {
    condition     = local.image_uri == "docker.io/myapp:latest"
    error_message = "The image was not set on the service correctly."
  }

  # make sure external_port is 80 because no cert or lb is enabled
  assert {
    condition     = local.external_port == 80
    error_message = "The external port was not set to 80."
  }

  # make sure var.lb.port is null
  assert {
    condition     = var.lb.port == null
    error_message = "The lb port was not set to null."
  }

  # make sure do_certificate is false
  assert {
    condition     = local.do_cert_lookup == false
    error_message = "The do_cert_lookup was not set to false."
  }

  # the cert arn chould be an empty string
  assert {
    condition     = local.cert_arn == ""
    error_message = "The cert arn should be an empty string by default"
  }

  assert {
    condition = length(duplocloud_k8s_job.before_update) == 0
    error_message = "There should be no before update job by default."
  }

  # make sure the local.env_from is an empty array by default
  assert {
    condition     = length(local.env_from) == 0
    error_message = "The env_from should be an empty array by default."
  }
}
