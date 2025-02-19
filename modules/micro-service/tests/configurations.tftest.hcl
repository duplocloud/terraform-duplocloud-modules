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
      name      = "bubbles"
      class       = "aws-secret"
      csi         = true
      managed     = false
      description = "This would build an aws secret with a k8s secret using a the csi driver. This then is mounted as a colume and envFrom"
      data = {
        BUBBLES = "are cool"
      }
      }, {
      type        = "files"
      description = "This should not show up in envFrom because this configuration is for a set of files. It should show up in the volumes though."
      data = {
        "hello.txt" = "hello world"
      }
      }, {
      enabled     = false
      name      = "disabled"
      class       = "aws-ssm"
      csi         = false
      managed     = true
      type        = "environment"
      description = "This should be disabled so it should not be in the envfrom"
      data = {
        "HELLO" = "world"
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
      length(local.configurations) == 4 &&
      # bc 1 external secret and two enabled configurations with type environment
      length(local.env_from) == 3 && 
      length(module.configurations) == 4
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

  # make sure the volumes look correct
  assert {
    condition = length(local.volumes) == 2 && local.volumes == [{
      name = "files"
      configMap = {
        name = "myapp-files"
      }
    },{
        name = "bubbles"
        csi = {
          driver   = "secrets-store.csi.k8s.io"
          readOnly = true
          volumeAttributes = {
            secretProviderClass = "myapp-bubbles"
          }
        }
      }]
    error_message = "The volumes was not set correctly."
  }

}
