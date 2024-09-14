provider "aws" {
  region              = var.region
  allowed_account_ids = var.provider_allowed_account_ids
  assume_role {
    role_arn = var.provider_assume_role_role_arn
  }
}

terraform {
  required_version = ">=1.5.3"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
