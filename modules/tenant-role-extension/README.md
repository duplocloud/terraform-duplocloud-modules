## Example 
```
locals {
  my_secrets_prefix = "SecretSauce"
  tenant_name = "dev01"
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}


data "aws_iam_policy_document" "example" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${local.aws_account_id}:secret:/${local.my_secrets_prefix}/*"]
  }
}

module "tenant-role" {
  source          = "duplocloud/components/duplocloud//modules/tenant-role-extension"
  version         = "0.0.19"
  tenant_name     = local.tenant_name
  iam_policy_json = data.aws_iam_policy_document.example.json
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_duplocloud"></a> [duplocloud](#requirement\_duplocloud) | ~> 0.9.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.custom_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_policy_json"></a> [iam\_policy\_json](#input\_iam\_policy\_json) | The IAM policy JSON which has the extra policies granted to the tenant role | `any` | n/a | yes |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | The name for the custom IAM policy created | `string` | `"custom-policy"` | no |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | The tenant name for which to extend the IAM role | `any` | n/a | yes |

## Outputs

No outputs.
