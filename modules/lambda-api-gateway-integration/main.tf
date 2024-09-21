####################################################################
# Locals
####################################################################

data "duplocloud_tenant" "tenant" {
  name = var.tenant_name
}

data "aws_iam_role" "tenant" {
  name = "duploservices-${var.tenant_name}"
}

locals {
  warmup_enabled_functions = [for func in var.functions : func.name if func.warmup_enabled]
  all_events = flatten([for func in var.functions : func.events != null ? [for e in func.events : {
    id                 = "${func.name}--${e.path}"
    function_name      = func.name
    path               = e.path
    method             = e.method
    cors               = e.cors
    content_handling   = e.content_handling
    authorization_type = lookup(e, "authorizer", null) != null ? lookup(e.authorizer, "type", null) : null
    authorizer_id      = lookup(e, "authorizer", null) != null ? lookup(e.authorizer, "id", null) : null
  }] : []])
  all_schedules = flatten([for func in var.functions : func.schedule != null ? [{
    id            = "${func.name}--schedule"
    function_name = func.name
    rate          = func.schedule.rate
    enabled       = func.schedule.enabled
    input         = func.schedule.input
  }] : []])
  all_event_bridge_rules = flatten([for func in var.functions : func.event_bridge != null ? [for i, p in func.event_bridge.pattern : {
    id                  = "${func.name}-event-bridge-rule-${i}"
    rule_index          = sum([i, 1])
    function_name       = func.name
    event_bus_arn       = func.event_bridge.event_bus_arn
    pattern_source      = p.source
    pattern_detail_type = p.detail_type
    pattern_detail      = lookup(p, "detail", null) != null ? p.detail : null
  }] : []])
}


####################################################################
# Create the Lambda function with API gateway integration
####################################################################

resource "duplocloud_aws_lambda_function" "lambda" {
  for_each = { for func in var.functions : func.name => func }

  tenant_id = data.duplocloud_tenant.tenant.id
  name      = "${var.service_name}-${var.tenant_name}-${each.key}"
  runtime   = var.serverless_common_config.function_runtime
  handler   = each.value.handler
  s3_bucket = var.serverless_common_config.function_source_code_bucket_name
  s3_key    = each.value["function_source_code_bucket_key"]

  dynamic "environment" {
    for_each = lookup(each.value, "environment_variables", null) != null ? [merge(var.serverless_common_config.environment_variables, each.value.environment_variables, each.value.warmup_enabled ? { "warmup_enabled" : "true" } : {})] : [merge(var.serverless_common_config.environment_variables, each.value.warmup_enabled ? { "warmup_enabled" : "true" } : {})]
    content {
      variables = environment.value
    }
  }

  timeout           = lookup(each.value, "timeout", 6)
  memory_size       = lookup(each.value, "memory_size", 1024)
  ephemeral_storage = lookup(each.value, "ephemeral_storage_size", "512")
  architectures     = contains(keys(each.value), "architectures") ? each.value.architectures : ["x86_64"]
  lifecycle {
    ignore_changes = [s3_bucket, s3_key]
  }
}


resource "duplocloud_aws_apigateway_event" "apigateway_event" {
  for_each           = { for e in local.all_events : e.id => e }
  tenant_id          = data.duplocloud_tenant.tenant.id
  api_gateway_id     = var.serverless_common_config.api_gateway_id
  method             = upper(each.value.method)
  path               = startswith(each.value.path, "/") ? each.value.path : "/${each.value.path}"
  cors               = each.value.cors
  content_handling   = each.value.content_handling
  authorization_type = each.value.authorization_type != null ? each.value.authorization_type : null
  authorizer_id      = each.value.authorizer_id != null ? each.value.authorizer_id : null

  integration {
    type    = "AWS_PROXY"
    uri     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${duplocloud_aws_lambda_function.lambda[each.value.function_name].arn}/invocations"
    timeout = lookup(each.value, "timeout", 29000)
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_api_gateway_deployment" "re_deployment" {
  count = length(local.all_events) > 0 ? 1 : 0
  depends_on = [
    duplocloud_aws_apigateway_event.apigateway_event,
  ]
  rest_api_id = var.serverless_common_config.api_gateway_id
  stage_name  = var.tenant_name
  description = "Deployed from terraform at ${timestamp()}"
  variables = {
    deployed_at = "Deployed from terraform at ${timestamp()}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

####################################################################
# Create schedules
####################################################################
resource "aws_scheduler_schedule" "schedule" {
  for_each = { for sc in local.all_schedules : sc.id => sc }
  name     = "${var.tenant_name}-${var.service_name}-${each.value.function_name}"

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = each.value.rate

  target {
    arn      = duplocloud_aws_lambda_function.lambda[each.value.function_name].arn
    role_arn = data.aws_iam_role.tenant.arn

    input = each.value.input != null ? each.value.input : null
  }
}

####################################################################
# Create event rules
####################################################################
resource "aws_cloudwatch_event_rule" "rule" {
  for_each    = { for ebr in local.all_event_bridge_rules : ebr.id => ebr }
  name        = "${var.service_name}-${var.tenant_name}-${each.value.function_name}-rule-${each.value.rule_index}"
  description = "Event bridge rule for Service: ${var.service_name}, Environment: ${var.tenant_name}, Target Function : ${each.value.function_name}"

  event_bus_name = each.value.event_bus_arn
  event_pattern = jsonencode(each.value.pattern_detail != null && each.value.pattern_detail_type != null ? ({
    source      = each.value.pattern_source
    detail-type = each.value.pattern_detail_type
    detail      = each.value.pattern_detail
    }) : each.value.pattern_detail_type != null ? ({
    source      = each.value.pattern_source
    detail-type = each.value.pattern_detail_type
    }) : ({
    source = each.value.pattern_source
  }))
}

resource "aws_cloudwatch_event_target" "rule_target" {
  for_each       = { for ebr in local.all_event_bridge_rules : ebr.id => ebr }
  arn            = duplocloud_aws_lambda_function.lambda[each.value.function_name].arn
  rule           = aws_cloudwatch_event_rule.rule[each.key].name
  event_bus_name = each.value.event_bus_arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  for_each      = { for ebr in local.all_event_bridge_rules : ebr.id => ebr }
  statement_id  = "AllowExecutionFromCloudWatchRule-${aws_cloudwatch_event_rule.rule[each.key].name}"
  action        = "lambda:InvokeFunction"
  function_name = duplocloud_aws_lambda_function.lambda[each.value.function_name].fullname
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule[each.key].arn
}

####################################################################
# Create the Warmup Lambda function
####################################################################

resource "duplocloud_aws_lambda_function" "warmup_lambda" {
  count     = var.enable_warmup_lambda || length(local.warmup_enabled_functions) > 0 ? 1 : 0
  tenant_id = data.duplocloud_tenant.tenant.id
  name      = "${var.service_name}-${var.tenant_name}-warmup"
  runtime   = "nodejs18.x"
  handler   = "warmer.handler"
  s3_bucket = var.serverless_common_config.function_source_code_bucket_name
  s3_key    = "warmer-lambda.zip"

  environment {
    variables = {
      "FUNCTION_PREFIX" = "${var.service_name}-${var.tenant_name}-"
    }
  }

  timeout           = 900
  memory_size       = 1024
  ephemeral_storage = 512
  architectures     = ["x86_64"]
}

# Lambda Permission to allow invocation from CloudWatch Events
resource "aws_lambda_permission" "warmup_allow_event_invocation" {
  count         = var.enable_warmup_lambda || length(local.warmup_enabled_functions) > 0 ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatchWarmup"
  action        = "lambda:InvokeFunction"
  function_name = duplocloud_aws_lambda_function.warmup_lambda[0].fullname
  principal     = "events.amazonaws.com"
}

# CloudWatch Events Rule to Schedule the Lambda Function
resource "aws_cloudwatch_event_rule" "warmup_schedule" {
  count               = var.enable_warmup_lambda || length(local.warmup_enabled_functions) > 0 ? 1 : 0
  name                = "${var.service_name}-${var.tenant_name}-warmup-schedule"
  description         = "Scheduled rule to invoke warmup Lambda function"
  schedule_expression = "rate(5 minutes)" # Change the rate as needed (e.g., rate(1 hour), cron(0 0 * * ? *))
}

# CloudWatch Events Target to specify the Lambda function to invoke
resource "aws_cloudwatch_event_target" "warmup_target" {
  count = var.enable_warmup_lambda || length(local.warmup_enabled_functions) > 0 ? 1 : 0
  rule  = aws_cloudwatch_event_rule.warmup_schedule[0].name
  arn   = duplocloud_aws_lambda_function.warmup_lambda[0].arn
}

# Enable DuploCloud ES logging
resource "aws_cloudwatch_log_subscription_filter" "cwl_lambda" {
  for_each        = { for func in var.functions : func.name => func if contains(var.es_logging_environments, var.tenant_name) }
  name            = "cwl-${var.service_name}-${var.tenant_name}-${each.key}"
  log_group_name  = "/aws/lambda/${var.service_name}-${var.tenant_name}-${each.key}"
  filter_pattern  = ""
  destination_arn = var.es_cwl_destination_arn
}
