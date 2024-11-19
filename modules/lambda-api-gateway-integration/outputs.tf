output "lambda_function_names" {
  description = "The names of the Lambda functions"
  value       = { for func in var.functions : func.name => duplocloud_aws_lambda_function.lambda[func.name].arn }
}
