mock_provider "google" {}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name       = "example"
  project_id = "example-project"
  location   = "us"
}

run "test_immutable_tags_for_docker" {
  command = plan

  assert {
    condition     = google_artifact_registry_repository.this[0].docker_config[0].immutable_tags == true
    error_message = "DOCKER repositories must have immutable tags."
  }

  assert {
    condition     = output.url == "us-docker.pkg.dev/example-project/example"
    error_message = "Docker url must be <location>-docker.pkg.dev/<project>/<name>."
  }
}

run "test_no_docker_config_for_python" {
  command = plan

  variables {
    format = "PYTHON"
  }

  assert {
    condition     = length(google_artifact_registry_repository.this[0].docker_config) == 0
    error_message = "Non-DOCKER repositories must not carry docker_config."
  }

  assert {
    condition     = output.url == "us-python.pkg.dev/example-project/example"
    error_message = "Non-Docker url must use the lowercase format host."
  }
}

run "test_cleanup_keep_n" {
  command = plan

  variables {
    keep_last_versions = 5
  }

  assert {
    condition     = google_artifact_registry_repository.this[0].cleanup_policy_dry_run == false
    error_message = "Cleanup policies must be enforced, not dry-run."
  }

  assert {
    condition     = one([for p in output.cleanup_policies : p.keep_count if p.id == "keep-recent"]) == 5 && one([for p in output.cleanup_policies : p.action if p.id == "keep-recent"]) == "KEEP"
    error_message = "keep-recent must KEEP the most recent keep_last_versions versions."
  }

  assert {
    condition     = one([for p in output.cleanup_policies : p.older_than if p.id == "delete-untagged"]) == "604800s" && one([for p in output.cleanup_policies : p.tag_state if p.id == "delete-untagged"]) == "UNTAGGED"
    error_message = "delete-untagged must delete untagged versions older than 7 days."
  }
}

run "test_format_validation" {
  command = plan

  variables {
    format = "RPM"
  }

  expect_failures = [var.format]
}

run "test_keep_last_versions_validation" {
  command = plan

  variables {
    keep_last_versions = 0
  }

  expect_failures = [var.keep_last_versions]
}

run "test_iam_members" {
  command = plan

  variables {
    reader_members = ["serviceAccount:r1@example-project.iam.gserviceaccount.com", "group:readers@example.com"]
    writer_members = ["serviceAccount:w1@example-project.iam.gserviceaccount.com"]
  }

  assert {
    condition     = length(google_artifact_registry_repository_iam_member.reader) == 2
    error_message = "One reader binding per reader member."
  }

  assert {
    condition     = length(google_artifact_registry_repository_iam_member.writer) == 1
    error_message = "One writer binding per writer member."
  }

  assert {
    condition     = alltrue([for m in google_artifact_registry_repository_iam_member.reader : m.role == "roles/artifactregistry.reader"]) && alltrue([for m in google_artifact_registry_repository_iam_member.writer : m.role == "roles/artifactregistry.writer"])
    error_message = "Reader and writer bindings must use the artifactregistry reader and writer roles."
  }
}

run "test_member_format_validation" {
  command = plan

  variables {
    reader_members = ["alice@example.com"]
  }

  expect_failures = [var.reader_members]
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "a23456789-123456789-123456789-123456789-123456789-123456789-1234"
  }

  expect_failures = [var.name]
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create         = false
    reader_members = ["group:readers@example.com"]
  }

  assert {
    condition     = output.id == null && output.name == null && output.self_link == null && output.url == null && output.labels == null && output.cleanup_policies == null
    error_message = "All outputs must be null when create is false."
  }

  assert {
    condition     = length(google_artifact_registry_repository.this) == 0 && length(google_artifact_registry_repository_iam_member.reader) == 0
    error_message = "No resources may be planned when create is false."
  }
}

run "test_tags_contract" {
  command = plan

  variables {
    labels = { owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { owner = "y", team = "z" }
    }
  }

  assert {
    condition     = output.labels.owner == "x"
    error_message = "var.labels must win over context.extra_tags."
  }

  assert {
    condition     = output.labels.team == "z"
    error_message = "context.extra_tags must be merged into labels."
  }
}
