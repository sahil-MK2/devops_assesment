terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local backend so `terraform init`/`plan` work without AWS credentials,
  # which keeps this assessment runnable without a real deployment.
  # For a real environment, replace this block with the S3 backend in
  # backend.hcl.example (separate bucket/key per environment for isolated state).
  backend "local" {
    path = "terraform.prod.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  # Plan-only / offline friendly: allows `terraform plan` to run without
  # real AWS credentials or connectivity, since no resources are actually applied.
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}
