terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = "~> 1.267"
      configuration_aliases = [alicloud.sls_project, alicloud.sls_resource_record]
    }
  }
  required_version = ">= 1.2"
}
