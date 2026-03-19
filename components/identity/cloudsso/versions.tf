terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = "~> 1.267"
      configuration_aliases = [alicloud.master, alicloud.iam]
    }
  }
  required_version = ">= 1.2"
}
