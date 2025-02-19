# only do plans here
run "building_configurations" {
  command = plan
  variables {
    tenant = "dev01"
    name   = "myapp"
    env = {
      FOO = "bar"
    }
    secrets = [
      "some-other-secret"
    ]
    configurations = [{
      data = {
        BAZ = "buzz"
      }
      }, {
      suffix = "-bubbles"
      class  = "aws-secret"
      csi    = true
      managed = false
      description = "This would build an aws secret with a k8s secret using a the csi driver. This then is mounted as a colume and envFrom"
      data = {
        BUBBLES = "are cool"
      }
      }, {
      class       = "configmap"
      type        = "files"
      description = "This should not show up in envFrom because this configuration is for a set of files."
      data = {
        "hello.txt" = "hello world"
      }
    }]
  }

  # make sure local.container_env has one value and it looks like {Name = "FOO", Value = "bar"}
  assert {
    condition = length(local.container_env) == 1 && local.container_env == [{
      name  = "FOO",
      value = "bar"
    }]
    error_message = "The container_env was not set correctly."
  }

  assert {
    condition = (
      length(local.configurations) == 3 &&
      length(local.env_from) == 3 &&
      length(module.configurations) == 3
    )
    error_message = "The configurations was not set correctly."
  }

  # make sure the env_from looks correct
  assert {
    condition = local.env_from == [{
      configMapRef = {
        name = "myapp-env"
      }
      }, {
      secretRef = {
        name = "myapp-bubbles"
      }
      }, {
      secretRef = {
        name = "some-other-secret"
      }
    }]
    error_message = "The env_from was not set correctly."
  }

}
