resource "aws_api_gateway_rest_api" "this" {
  count = var.type == "rest" ? 1 : 0
  name  = local.fullname

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  body = yamlencode(local.body)
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_api_gateway_deployment" "this" {
  count = var.type == "rest" ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this[0].id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this[0].body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  count = var.type == "rest" ? 1 : 0

  stage_name    = "default"
  deployment_id = aws_api_gateway_deployment.this[0].id
  rest_api_id   = aws_api_gateway_rest_api.this[0].id
}

resource "aws_api_gateway_vpc_link" "this" {
  count       = var.enable_private_link ? var.type != "rest" ? 1 : 0 : 0
  name        = local.fullname
  description = "Private connections for ${var.name} in ${var.tenant_name}"
  target_arns = var.vpc_link_targets
}

resource "aws_api_gateway_domain_name" "this" {
  count                    = var.type == "rest" ? 1 : 0
  domain_name              = local.domain
  regional_certificate_arn = data.duplocloud_plan_certificate.this.arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "rest_gateway" {
  count = var.type == "rest" ? 1 : 0

  name    = aws_api_gateway_domain_name.this[0].domain_name
  type    = "A"
  zone_id = local.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.this[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this[0].regional_zone_id
    evaluate_target_health = false
  }
}
