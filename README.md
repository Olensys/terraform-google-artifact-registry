# terraform-google-artifact-registry

Artifact Registry repository with immutable Docker tags, cleanup policies that keep the last N versions, and reader and writer IAM

## Opinions

- Docker repositories always have immutable tags (`docker_config.immutable_tags = true`); other formats carry no `docker_config`.
- Cleanup policies are enforced, not dry-run: for DOCKER, untagged versions older than 7 days are deleted (tags are a Docker concept, so other formats skip this rule); every format always keeps the most recent `keep_last_versions` (default 30) versions.
- IAM is additive and per member: `roles/artifactregistry.reader` for `reader_members`, `roles/artifactregistry.writer` for `writer_members`. Members need a `user:`, `serviceAccount:`, `group:` or `domain:` prefix.
- `url` is `<location>-docker.pkg.dev/<project>/<name>` for DOCKER and `<location>-<format>.pkg.dev/<project>/<name>` (format lowercased) for NPM, PYTHON and MAVEN; GENERIC repositories have no registry host, so `url` is null.
- `self_link` is the repository resource name, `projects/<project>/locations/<location>/repositories/<name>`.

## Usage

```hcl
module "this" {
  source = "git::https://github.com/Olensys/terraform-google-artifact-registry.git?ref=v1.0.0"

  name       = "example"
  project_id = "my-project"
  location   = "us"
  context = {
    organization = "olensys"
    environment  = "dev"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.0, < 8.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_artifact_registry_repository.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_artifact_registry_repository_iam_member.writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the repository: a region such as europe-west1 or a multi-region such as us. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Repository id. Lowercase letters, digits and hyphens, starting with a letter. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project that will own the repository. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to plan nothing. | `bool` | `true` | no |
| <a name="input_format"></a> [format](#input\_format) | Repository format: DOCKER, NPM, PYTHON, MAVEN or GENERIC. | `string` | `"DOCKER"` | no |
| <a name="input_keep_last_versions"></a> [keep\_last\_versions](#input\_keep\_last\_versions) | Number of most recent versions the cleanup policy always keeps. | `number` | `30` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Cloud KMS crypto key (projects/.../cryptoKeys/...) used to encrypt the repository. Null uses Google-managed encryption. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels merged onto the repository, applied last. | `map(string)` | `{}` | no |
| <a name="input_reader_members"></a> [reader\_members](#input\_reader\_members) | IAM members granted roles/artifactregistry.reader, each prefixed user:, serviceAccount:, group: or domain:. | `list(string)` | `[]` | no |
| <a name="input_writer_members"></a> [writer\_members](#input\_writer\_members) | IAM members granted roles/artifactregistry.writer, each prefixed user:, serviceAccount:, group: or domain:. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cleanup_policies"></a> [cleanup\_policies](#output\_cleanup\_policies) | The cleanup policies passed to the repository (delete-untagged after 7 days for DOCKER only, keep-recent for every format). Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Terraform ID of the repository, projects/<project>/locations/<location>/repositories/<name>. Null when create is false. |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels applied to the repository, with context.extra\_tags merged in. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Repository id (the name passed in). Null when create is false. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Resource name of the repository, projects/<project>/locations/<location>/repositories/<name>. Null when create is false. |
| <a name="output_url"></a> [url](#output\_url) | Registry URL: <location>-docker.pkg.dev/<project>/<name> for DOCKER, <location>-<format>.pkg.dev/<project>/<name> for NPM, PYTHON and MAVEN. Null for GENERIC (no registry host) and when create is false. |
<!-- END_TF_DOCS -->
