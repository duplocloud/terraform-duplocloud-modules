
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
  version         = "0.0.8"
  tenant_name     = local.tenant_name
  iam_policy_json = data.aws_iam_policy_document.example.json
}

