# only do plans here
run "validate_defaults" {
  command = plan
  variables {
    tenant_id = "2cf9a5bd-311c-47d3-93be-df812e98e775"
  }

  # make sure the managed configmap resource has a count of 1
  assert {
    condition     = length(duplocloud_k8_config_map.managed) == 1
    error_message = "The managed configmap resource should have a count of 1."
  }

  # make sure the configuration var looks right
  assert {
    condition     = local.configurations.configmap.value != null && local.configurations.secret.value == null && local.configurations.aws-secret.value == null && local.configurations.aws-ssm.value == null
    error_message = "The configuration var should be set to myapp."
  }

  # the real name should be myapp
  assert {
    condition     = local.realName == "env"
    error_message = "The real name should just be the default 'env' because type is defaulted to environment."
  }
}

run "unmanaged_configmap" {
  command = plan
  variables {
    tenant_id = "2cf9a5bd-311c-47d3-93be-df812e98e775"
    name      = "conf"
    prefix    = "myapp"
    managed   = false
  }

  # make sure the managed configmap resource has a count of 1
  assert {
    condition     = length(duplocloud_k8_config_map.managed) == 0
    error_message = "There should be no managed configmap resource."
  }
  assert {
    condition     = length(duplocloud_k8_config_map.unmanaged) == 1
    error_message = "There should be one unmanaged configmap resource."
  }
  # the name should be myapp-conf
  assert {
    condition     = local.name == "myapp-conf"
    error_message = "The name should be myapp-conf."
  }

}
