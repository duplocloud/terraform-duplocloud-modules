resource "aws_apigatewayv2_api" "this" {
  count = var.type == "http" ? 1 : 0
  name          = local.fullname
  description   = "Gateway for ${var.name} within ${var.tenant_name}"
  protocol_type = "HTTP"
  tags          = local.base_tags
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
    max_age       = 600
  }
  lifecycle {
    ignore_changes = [
      body,
      tags,
      tags_all,
      version
    ]
  }
}

resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.type == "http" ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  domain_name = aws_apigatewayv2_domain_name.this[0].id
  stage       = aws_apigatewayv2_stage.default[0].id
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  count = var.type == "http" ? 1 : 0
  name = "/${var.tenant_name}/gateway/${var.name}"
  tags = local.base_tags
}

resource "aws_apigatewayv2_stage" "default" {
  count = var.type == "http" ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  name        = "default"
  auto_deploy = true
  tags        = local.base_tags

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
    format = jsonencode({
      "requestId" : "$context.requestId",
      "ip" : "$context.identity.sourceIp",
      "requestTime" : "$context.requestTime",
      "httpMethod" : "$context.httpMethod",
      "routeKey" : "$context.routeKey",
      "status" : "$context.status",
      "protocol" : "$context.protocol",
      "responseLength" : "$context.responseLength",
      "path" : "$context.path",
      "basePathMatched" : "$context.customDomain.basePathMatched"
    })
  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
  count = var.enable_private_link ? var.type == "http" ? 1 : 0  : 0
  name  = local.fullname
  security_group_ids = [
    local.sg_infra[index(local.sg_infra.*.name, "duplo-allhosts")].id,
    data.aws_security_group.tenant.id
  ]
  subnet_ids = data.duplocloud_tenant_internal_subnets.this.subnet_ids
  tags       = local.base_tags
}

resource "aws_apigatewayv2_domain_name" "this" {
  count = var.type == "http" ? 1 : 0
  domain_name = local.domain
  domain_name_configuration {
    certificate_arn = data.duplocloud_plan_certificate.this.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  tags = local.base_tags
}

resource "aws_route53_record" "http_gateway" {
  count = var.type == "http" ? 1 : 0
  name    = aws_apigatewayv2_domain_name.this[0].domain_name
  type    = "A"
  zone_id = local.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
