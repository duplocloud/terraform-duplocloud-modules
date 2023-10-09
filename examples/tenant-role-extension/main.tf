terraform {
  required_version = ">= 1.4.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.12.0"
    }
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = "> 0.9.40"
    }
  }
}
locals {
  my_secrets_prefix = "SecretSauce"
  tenant_name       = "dev01"
  aws_account_id    = "abc123"
}

# data "aws_caller_identity" "current" {
# }

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
  source          = "../..//modules/tenant-role-extension"
  tenant_name     = local.tenant_name
  iam_policy_json = data.aws_iam_policy_document.example.json
}

