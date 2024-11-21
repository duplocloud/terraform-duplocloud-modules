terraform {
  required_version = "~> 1.9.7"

  # experiments = [module_variable_optional_attrs]

  required_providers {
    aws        = { version = "~> 5.70.0" }

    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = "~> 0.10.48"
    }
  }
}

provider "duplocloud" {}
provider "aws" {
  region = var.region
}

// S3 buckets with "normal" security settings.
resource "duplocloud_s3_bucket" "bucket" {
  # lifecycle { ignore_changes = all } //temporary for new usa prod s3 bucket replication
  for_each = var.s3_buckets

  tenant_id = var.tenant_id
  name      = each.key

  allow_public_access = coalesce(lookup(each.value, "allow-public", null), lookup(each.value, "public", null), false)
  enable_versioning   = false
  enable_access_logs  = true
  managed_policies    = ["ignore"]
  default_encryption {
    method = "Sse" # For even stricter security, use "TenantKms" here.
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  for_each = var.s3_buckets

  bucket = duplocloud_s3_bucket.bucket[each.key].fullname
  rule {
    object_ownership = "ObjectWriter"
  }
}

// S3 bucket ACLs
resource "aws_s3_bucket_acl" "bucket" {
  for_each = var.s3_buckets

  bucket = duplocloud_s3_bucket.bucket[each.key].fullname
  # acl    = lookup(each.value, "public", false) ? "public-read" : "private"
  acl = coalesce(lookup(each.value, "public", null), false) ? "public-read" : "private"

  depends_on = [aws_s3_bucket_ownership_controls.bucket]
}

// S3 bucket CORS settings
resource "aws_s3_bucket_cors_configuration" "this" {
  for_each = { for k, v in var.s3_buckets : k => v if coalesce(lookup(v, "cors", null), false) }

  bucket = duplocloud_s3_bucket.bucket[each.key].fullname

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

// S3 bucket policies
data "aws_iam_policy_document" "s3-buckets" {
  for_each = var.s3_buckets

  statement {
    sid    = "DefaultAllow"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${var.partition}:iam::${var.aws_account_id}:root"]
    }
    actions = ["s3:*"]
    resources = [
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.bucket[each.key].fullname}/*",
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.bucket[each.key].fullname}"
    ]
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.bucket[each.key].fullname}/*",
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.bucket[each.key].fullname}"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = coalesce(lookup(each.value, "public", null), false) ? [true] : []

    content {
      sid    = "AllowPublicRead"
      effect = "Allow"
      principals {
        type        = "*"
        identifiers = ["*"]
      }
      actions = ["s3:GetObject"]
      resources = [
        "arn:${var.partition}:s3:::${duplocloud_s3_bucket.bucket[each.key].fullname}/*"
      ]
    }
  }
}
resource "aws_s3_bucket_policy" "bucket" {
  lifecycle { ignore_changes = all } //temporary for new usa prod s3 bucket replication
  for_each = var.s3_buckets

  bucket = duplocloud_s3_bucket.bucket[each.key].fullname
  policy = data.aws_iam_policy_document.s3-buckets[each.key].json
}

/*
// ALB access log bucket
// ALB access log S3 bucket with "normal" security settings.
resource "duplocloud_s3_bucket" "alb-access-log" {

  tenant_id = var.ingress_tenant_id
  name      = "alb-access-log"

  allow_public_access = false
  enable_versioning   = false
  enable_access_logs  = true
  managed_policies    = ["ignore"]
  default_encryption {
    method = "Sse" # For even stricter security, use "TenantKms" here.
  }
}

locals {
  internal_alb_log_prefix = "internal-alb-logs"
  external_alb_log_prefix = "external-alb-logs"
}

data "aws_elb_service_account" "main" {}

// S3 bucket policies
data "aws_iam_policy_document" "alb-access-log-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.alb-access-log.fullname}",
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.alb-access-log.fullname}/${var.internal_alb_log_prefix}/AWSLogs/${var.aws_account_id}/*",
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.alb-access-log.fullname}/${var.external_alb_log_prefix}/AWSLogs/${var.aws_account_id}/*",
    ]
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.alb-access-log.fullname}/*",
      "arn:${var.partition}:s3:::${duplocloud_s3_bucket.alb-access-log.fullname}"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb-access-log-lifecycle" {
  bucket = duplocloud_s3_bucket.alb-access-log.fullname

  rule {
    id      = "expire_external_logs"
    status = "Enabled"

    filter {
      prefix = "external-alb-logs/"
    }

    expiration {
      days = 30
    }
  }

  rule {
    id      = "expire_internal_logs"
    status = "Enabled"

    filter {
      prefix = "internal-alb-logs/"
    }

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "alb-access-log-policy" {

  bucket = duplocloud_s3_bucket.alb-access-log.fullname
  policy = data.aws_iam_policy_document.alb-access-log-policy.json
}
*/
/*
// US/Prod 'preview.pypestream.com' bucket - bucket name needs to match hostname for DNS CNAME alias to s3 bucket

// S3 buckets with "normal" security settings.
resource "aws_s3_bucket" "preview-s3-bucket" {
  count   = var.create_preview_bucket ? 1 : 0

  bucket  = "test.preview.pypestream.com"
}

resource "aws_s3_bucket_ownership_controls" "preview-s3-bucket" {
  count   = var.create_preview_bucket ? 1 : 0

  bucket = aws_s3_bucket.preview-s3-bucket[0].id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "preview-s3-bucket" {
  count   = var.create_preview_bucket ? 1 : 0

  bucket = aws_s3_bucket.preview-s3-bucket[0].id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_cors_configuration" "preview-s3-bucket" {
  count   = var.create_preview_bucket ? 1 : 0

  bucket = aws_s3_bucket.preview-s3-bucket[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "preview-s3-bucket" {
  count   = var.create_preview_bucket ? 1 : 0

  bucket = aws_s3_bucket.preview-s3-bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

// S3 bucket ACLs
resource "aws_s3_bucket_acl" "preview-s3-bucket" {
  count   = var.create_preview_bucket ? 1 : 0

  bucket = aws_s3_bucket.preview-s3-bucket[0].id
  acl    = "public-read"

  depends_on = [aws_s3_bucket_ownership_controls.preview-s3-bucket]
}

// S3 bucket policies
data "aws_iam_policy_document" "preview-s3-bucket" {
  statement {
    sid    = "DefaultAllow"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${var.partition}:iam::${var.aws_account_id}:root"]
    }
    actions = ["s3:*"]
    resources = [
      "arn:${var.partition}:s3:::${aws_s3_bucket.preview-s3-bucket[0].id}/*",
      "arn:${var.partition}:s3:::${aws_s3_bucket.preview-s3-bucket[0].id}"
    ]
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "arn:${var.partition}:s3:::${aws_s3_bucket.preview-s3-bucket[0].id}/*",
      "arn:${var.partition}:s3:::${aws_s3_bucket.preview-s3-bucket[0].id}"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = [
      "arn:${var.partition}:s3:::${aws_s3_bucket.preview-s3-bucket[0].id}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "preview-s3-bucket" {
  count   = var.create_preview_bucket ? 1 : 0

  bucket = aws_s3_bucket.preview-s3-bucket[0].id
  policy = data.aws_iam_policy_document.preview-s3-bucket.json
}
*/