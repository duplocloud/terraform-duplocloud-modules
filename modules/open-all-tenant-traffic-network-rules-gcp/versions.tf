terraform {
  required_version = ">= 1.2.4"
  required_providers {
    # google = {source = "hashicorp/google"
    #           version  = "~>5.31.1"
    #           }
    duplocloud = {source = "duplocloud/duplocloud"
                  version = ">= 0.10.29"
                  }
    # random = {
    #   source = "hashicorp/random"
    #   version = "3.6.2"
    }
  # }
}
