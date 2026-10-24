terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = { source = "hashicorp/google", version = ">= 6.0, < 8.0" }
  }
}

variable "project_id" {
  description = "GCP project that will own the repository."
  type        = string
}

locals {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "ar"
    owner        = "platform"
    cost_center  = "eng"
  }
}

module "naming" {
  source = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"

  context = local.context
}

module "this" {
  source = "../../"

  name       = "olensys-test-ar"
  context    = local.context
  project_id = var.project_id
  labels     = module.naming.labels

  location = "us"
}

output "url" {
  description = "Registry URL of the example repository."
  value       = module.this.url
}
