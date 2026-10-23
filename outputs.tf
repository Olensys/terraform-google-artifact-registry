output "id" {
  description = "Terraform ID of the repository, projects/<project>/locations/<location>/repositories/<name>. Null when create is false."
  value       = try(google_artifact_registry_repository.this[0].id, null)
}

output "name" {
  description = "Repository id (the name passed in). Null when create is false."
  value       = var.create ? var.name : null
}

output "self_link" {
  description = "Resource name of the repository, projects/<project>/locations/<location>/repositories/<name>. Null when create is false."
  value       = try(google_artifact_registry_repository.this[0].name, null)
}

output "url" {
  description = "Registry URL: <location>-docker.pkg.dev/<project>/<name> for DOCKER, <location>-<format>.pkg.dev/<project>/<name> otherwise. Null when create is false."
  value       = var.create ? "${local.url_host}/${var.project_id}/${var.name}" : null
}

output "labels" {
  description = "Labels applied to the repository, with context.extra_tags merged in. Null when create is false."
  value       = var.create ? local.labels : null
}

output "cleanup_policies" {
  description = "The cleanup policies passed to the repository (delete-untagged after 7 days, keep-recent). Null when create is false."
  value       = var.create ? local.cleanup_policies : null
}
