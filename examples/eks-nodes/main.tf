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
  source  = "duplocloud/components/aws//modules/aws-eks-nodes"
  version = "0.0.1"
  tenant_id = "24f71075-5a40-49ba-9f18-e3d034baa4b0"
  prefix = "fun-"
  instance_count = 1
  min_instance_count = 1
  max_instance_count = 1
  capacity = "m5.large"
  os_disk_size = 20
  eks_version = "1.24"
}
