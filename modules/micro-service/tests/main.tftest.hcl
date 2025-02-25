mock_provider "duplocloud" {
  mock_data "duplocloud_tenant" {
    defaults = {
      id      = "1234567890"
      name    = "tf-tests"
      plan_id = "myinfra"
    }
  }
  mock_data "duplocloud_plan_certificate" {
    defaults = {
      arn     = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
      name    = "mycert"
      plan_id = "myinfra"
    }
  }
  mock_data "duplocloud_k8_secret_provider_class" {
    defaults = {
      tenant_id       = "1234567890"
      name            = "valuetime"
      secret_provider = "aws"
    }
  }
}
