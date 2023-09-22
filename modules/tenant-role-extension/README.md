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
