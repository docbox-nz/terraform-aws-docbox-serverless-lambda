terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.54.0"
    }
  }

  required_version = ">= 1.2.0"
}


locals {
  serverless_repo     = "docbox-nz/docbox-serverless-lambda"
  serverless_version  = "0.0.2"
  serverless_base_url = "https://github.com/${local.serverless_repo}/releases/download/${local.serverless_version}"
  serverless_zip_arch = var.architecture == "x86_64" ? "amd64" : "arm64"
  shared_environment_variables = merge(var.environment_variables, {
    RUST_LOG = "debug,docbox_core::notifications::sqs=info"
  })
}
