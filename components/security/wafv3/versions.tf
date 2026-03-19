terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "~> 1.267"
    }
  }
  required_version = ">= 0.12"
}
