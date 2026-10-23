# Run only by the nightly integration workflow, against real cloud credentials.
# Set TF_VAR_project_id to a sandbox project.
run "apply_minimal" {
  command = apply

  module {
    source = "./examples/minimal"
  }

  assert {
    condition     = can(regex("^us-docker\\.pkg\\.dev/", output.url))
    error_message = "Docker repository url must use the us-docker.pkg.dev host."
  }
}
