resource "duplocloud_aws_lambda_function" "myfunction" {
  tenant_id   = duplocloud_tenant.this.tenant_id
  name        = var.function_name
  description = "A description of my function"

  package_type = var.package_type
  runtime   = var.package_type == "Zip" ? var.runtime : null
  handler   = var.package_type == "Zip" ? var.handler : null
  s3_bucket = var.package_type == "Zip" ? var.s3_bucket : null
  s3_key    = var.package_type == "Zip" ? var.s3_key : null

  image_uri    = var.package_typ == "Image" ? var.image_uri : null

  dynamic image_config {
    command           = ["echo", "hello world"]
    entry_point       = ["echo hello workd"]
    working_directory = "/tmp3"
  }

  tracing_config {
    mode = "PassThrough"
  }


  environment {
    variables = {
      "foo" = "bar"
    }
  }

  timeout     = 60
  memory_size = 512
}

resource "duplocloud_aws_lambda_function" "thisfunction" {

  tenant_id   = duplocloud_tenant.this.tenant_id
  name        = "thisfunction"
  description = "A description of my function"

  package_type = "Image"
  image_uri    = "dkr.ecr.us-west-2.amazonaws.com/myimage:latest"

  image_config {
    command           = ["echo", "hello world"]
    entry_point       = ["echo hello workd"]
    working_directory = "/tmp3"
  }

  tracing_config {
    mode = "PassThrough"
  }

  timeout     = 60
  memory_size = 512
}

resource "duplocloud_aws_lambda_function" "edgefunction" {
  tenant_id   = "c7163b39-43ca-4d44-81ce-9a323087039b"
  name        = "edgefunction"
  description = "An example edge function"

  package_type = "Image"
  image_uri    = "dkr.ecr.us-east-1.amazonaws.com/myimage:1.0"

  image_config {
    command           = ["echo", "hello world"]
    entry_point       = ["echo hello workd"]
    working_directory = "/tmp3"
  }

  tags = {
    IsEdgeDeploy = true
  }

  timeout     = 5
  memory_size = 128
}
