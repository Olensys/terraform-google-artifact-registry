# Changelog

## [1.1.1](https://github.com/Olensys/terraform-google-artifact-registry/compare/v1.1.0...v1.1.1) (2026-10-24)


### Bug Fixes

* **examples:** pin naming module to v1.0.1 ([fddd5bb](https://github.com/Olensys/terraform-google-artifact-registry/commit/fddd5bb64084ba6a0b9bb3983da6013c8d395565))
* run integration on change and weekly instead of nightly ([9aff8db](https://github.com/Olensys/terraform-google-artifact-registry/commit/9aff8dbdfd85c574cb84c873510df741ec863969))

## 1.1.0

### Fixes

- normalise `context.extra_tags` keys and values to valid GCP label syntax (lowercase, `[^a-z0-9_-]` replaced by `-`, 63 characters); `labels` are applied verbatim and win

### Tests

- `test_tags_contract` now covers mixed-case extra tags and verifies normalisation

### Docs

- Usage shows the naming module; Opinions describe label normalisation

### Behaviour changes

- `labels` output and applied labels now contain normalised keys and values for `context.extra_tags` (for example `Team = "Core Team"` becomes `team = "core-team"`). Callers that relied on mixed-case or space-containing extra tags must expect the normalised form; values passed in `labels` are unchanged.

## 1.0.1

### Fixes

- limit delete-untagged to DOCKER and return null url for GENERIC

### Docs

- fix opinions wording

## 1.0.0

- Artifact Registry repository with immutable tags for DOCKER, enforced cleanup policies (delete untagged after 7 days, keep the most recent N versions), optional CMEK, and reader and writer IAM bindings.
