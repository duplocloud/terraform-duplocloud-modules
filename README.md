# Duplocloud Terraform Modules  

[![Module Tests](https://github.com/duplocloud/terraform-duplocloud-components/actions/workflows/test.yml/badge.svg)](https://github.com/duplocloud/terraform-duplocloud-components/actions/workflows/test.yml)

A collection of common cloud patterns built on top of the official Duplocloud Terraform provider. Use these to greatly speed up your TF journey. 

## Testing  

To run the unit tests when in a module directory:  
```sh
tf test -filter=tests/unit.tftest.hcl
```

## General Usage  

To use a module in your project, add the following to your `some.tf` file:  
```hcl
module "components" {
  source  = "duplocloud/components/duplocloud"
  version = "0.0.22"
}
```
