terraform {
  required_version = ">= 1.4.4"
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = ">= 0.10.40"
    }
  }
  backend "s3" {
    workspace_key_prefix = "duplocloud/components"
    key                  = "lambda-api-gateway-integration"
    encrypt              = true
  }
}

provider "duplocloud" {
}

provider "aws" {
  region = "us-west-2"
}


data "duplocloud_tenant" "current" {
  name = "tf-tests"
}

module "lambda_agw_integration" {
  source               = "../../modules/lambda-api-gateway-integration"
  region               = "us-west-2"
  service_name         = "valuation"
  tenant_name          = data.duplocloud_tenant.current.name
  enable_warmup_lambda = false
  serverless_common_config = {   # Common attibutes across lambda functions
    function_runtime                 = "nodejs18.x"
    function_source_code_bucket_name = "duploservices-tf-tests-lambda"
    api_gateway_id                   = "1234567890"
    environment_variables = {
      Environment = "Staging"
      CreatedBy   = "Duplo"
    }
  }
  functions = [

    {
      name                            = "health"
      handler                         = "src/functions/health/index.health"
      function_source_code_bucket_key = "health.zip"
      timeout                         = 25
      events = [{
        path : "v1/health"
        method : "get"
        cors : true
        },
        # API Gateway Lambda Integration with authorizer
        {
          path : "v2/health"
          method : "get"
          cors : true
          authorizer : {
            id   = "4ebogt" # Authorizer ID
            type = "COGNITO_USER_POOLS"
          }
      }]
    },
    # Cloudwatch schedule and Lambda Integration
    {
      name                            = "cancelStalePendingApps"
      handler                         = "src/functions/cancelStalePendingApps/index.handler"
      function_source_code_bucket_key = "test.zip"
      schedule = {
        rate    = "cron(7 3 * * ? *)"
        enabled = true
      }
    },
    # Cloudwatch event rule custom pattern and Lambda Integration
    {
      name                            = "getPeachData"
      handler                         = "src/functions/getPeachData/index.handler"
      function_source_code_bucket_key = "sample.zip"
      event_bridge = {
        event_bus_arn = "arn:aws:events:us-west-2:123456789012:event-bus/web-event-bus"
        pattern = [
          {
            source      = ["test.data-service"],
            detail_type = ["get-data"],
          }
        ]
      }
    }
  ]
}
