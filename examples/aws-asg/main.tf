terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.12.0"
    }
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = "> 0.9.40"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "duplocloud" {

}

module "asg" {
  source = "../../modules/aws-asg"
  tenant_id = "123abc"
  prefix = "fun-"
  instance_count = 1
  min_instance_count = 1
  max_instance_count = 1
  capacity = "m5.large"
  os_disk_size = 20
  eks_version = "1.24"
}
