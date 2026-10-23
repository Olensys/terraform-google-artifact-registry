locals {
  labels = merge(var.context.extra_tags, var.labels)

  is_docker = var.format == "DOCKER"

  # Uniform shape so one dynamic block renders every policy. Tags are a
  # Docker concept, so delete-untagged only applies to DOCKER repositories.
  cleanup_policies = concat(
    local.is_docker ? [
      {
        id         = "delete-untagged"
        action     = "DELETE"
        tag_state  = "UNTAGGED"
        older_than = "604800s"
        keep_count = null
      },
    ] : [],
    [
      {
        id         = "keep-recent"
        action     = "KEEP"
        tag_state  = null
        older_than = null
        keep_count = var.keep_last_versions
      },
    ],
  )

  url_host = local.is_docker ? "${var.location}-docker.pkg.dev" : "${var.location}-${lower(var.format)}.pkg.dev"
}

resource "google_artifact_registry_repository" "this" {
  count = var.create ? 1 : 0

  project       = var.project_id
  location      = var.location
  repository_id = var.name
  format        = var.format
  description   = "${var.context.application} ${var.context.environment} ${var.format} repository managed by Terraform"
  labels        = local.labels
  kms_key_name  = var.kms_key_name

  cleanup_policy_dry_run = false

  dynamic "docker_config" {
    for_each = local.is_docker ? [1] : []

    content {
      immutable_tags = true
    }
  }

  dynamic "cleanup_policies" {
    for_each = local.cleanup_policies

    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = cleanup_policies.value.action == "DELETE" ? [1] : []

        content {
          tag_state  = cleanup_policies.value.tag_state
          older_than = cleanup_policies.value.older_than
        }
      }

      dynamic "most_recent_versions" {
        for_each = cleanup_policies.value.action == "KEEP" ? [1] : []

        content {
          keep_count = cleanup_policies.value.keep_count
        }
      }
    }
  }
}

resource "google_artifact_registry_repository_iam_member" "reader" {
  for_each = var.create ? toset(var.reader_members) : toset([])

  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.this[0].name
  role       = "roles/artifactregistry.reader"
  member     = each.value
}

resource "google_artifact_registry_repository_iam_member" "writer" {
  for_each = var.create ? toset(var.writer_members) : toset([])

  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.this[0].name
  role       = "roles/artifactregistry.writer"
  member     = each.value
}
