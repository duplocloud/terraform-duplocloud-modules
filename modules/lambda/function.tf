resource "duplocloud_aws_lambda_function" "this" {
  tenant_id   = data.duplocloud_tenant.this.id
  name        = var.name
  description = "${var.description}"

  package_type = var.package_type
  image_uri    = var.image.uri

  image_config {
    command           = [var.handler]
    entry_point       = var.image.entry_point
    working_directory = var.image.working_directory
  }

  tracing_config {
    mode = var.tracing_mode
  }

  timeout     = var.timeout
  memory_size = var.memory_size
  
}
#resource "duplocloud_aws_lambda_permission" "permission" {
#  statement_id  = "AllowExecutionFromAPIGateway"
#  action        = "lambda:InvokeFunction"
#  function_name = duplocloud_aws_lambda_function.myfunction.fullname
#  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
#  source_arn = "arn:aws:execute-api:region:accountId:aws_api_gateway_rest_api.api.id/*/*/*"
#  tenant_id  = "mytenant"
#}
