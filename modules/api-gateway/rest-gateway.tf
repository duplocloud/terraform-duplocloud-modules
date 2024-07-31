resource "aws_api_gateway_rest_api" "this" {
  name = local.fullname

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  lifecycle {
    ignore_changes = [
      tags,
      body
    ]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  stage_name    = "default"
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_vpc_link" "this" {
  count = var.enable_private_link ? var.type != "http" ? 1 : 0 : 0
  name        = local.fullname
  description = "Private connections for ${var.name} in ${var.tenant_name}"
  target_arns = var.vpc_link_targets
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name     = local.domain
  certificate_arn = data.duplocloud_plan_certificate.this.arn
}

# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "rest_gateway" {
  name    = aws_api_gateway_domain_name.this.domain_name
  type    = "A"
  zone_id = local.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
    evaluate_target_health = false
  }
}
