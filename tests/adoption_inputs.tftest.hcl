# Pass-through inputs that let a caller import an existing repository
# without a live change. Every default reproduces the previous hard-coded value.
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

run "test_immutable_tags_default_true" {
  command = plan

  assert {
    condition     = google_artifact_registry_repository.this[0].docker_config[0].immutable_tags == true
    error_message = "immutable_tags must default to true, the previous hard-coded value."
  }
}

run "test_immutable_tags_opt_out" {
  command = plan

  variables {
    immutable_tags = false
  }

  assert {
    condition     = google_artifact_registry_repository.this[0].docker_config[0].immutable_tags == false
    error_message = "immutable_tags = false must be passed through to docker_config."
  }
}

run "test_immutable_tags_ignored_for_non_docker" {
  command = plan

  variables {
    format         = "PYTHON"
    immutable_tags = false
  }

  assert {
    condition     = length(google_artifact_registry_repository.this[0].docker_config) == 0
    error_message = "Non-DOCKER repositories must not carry docker_config even when immutable_tags is set."
  }
}
