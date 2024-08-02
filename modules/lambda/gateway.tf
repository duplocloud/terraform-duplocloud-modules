resource "duplocloud_aws_lambda_permission" "permission" {
  count         = var.api_gateway != null ? 1 : 0
  tenant_id     = local.tenant_id
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = duplocloud_aws_lambda_function.this.fullname
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${var.api_gateway.id}/${var.api_gateway.permission}"
}
