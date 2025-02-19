resource "duplocloud_k8_secret_provider_class" "aws" {
  count           = contains(["aws-secret", "aws-ssm"], var.class) && var.csi ? 1 : 0
  tenant_id       = var.tenant_id
  name            = var.name
  secret_provider = "aws"

  # Here we use jmespath to alias the individual fields in the secret to names that are
  # more friendly for environment variables.
  # We pulled in both values from the secret, but you could pull in whatever you want.

  parameters = yamlencode(
    [
      {
        objectName = var.name,
        objectType = var.class == "aws-secret" ? "secretsmanager" : "ssmparameter",
        jmesPath = [
          for key in local.keys : {
            path        = key
            objectAlias = key
          }
        ]
      }
    ]
  )

  # We use the aliased fields to populate the K8s secret.  
  #Here we'll get a secret named fields-from-secret-manager with two keys:
  # MYFIRSTSECRETENVVAR and MYSECONDSECRETENVVAR, 
  # with their corresponding secret values.

  secret_object {
    name = var.name
    type = "Opaque"
    dynamic "data" {
      for_each = local.keys
      content {
        key         = data.value
        object_name = data.value
      }
    }
  }
}
