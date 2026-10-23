variable "name" {
  description = "Repository id. Lowercase letters, digits and hyphens, starting with a letter."
  type        = string
  validation {
    condition     = length(var.name) <= 63 && can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.name))
    error_message = "name must be at most 63 characters and match ^[a-z]([a-z0-9-]*[a-z0-9])?$."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "project_id" {
  description = "GCP project that will own the repository."
  type        = string
}

variable "create" {
  description = "Whether to create any resources. Set false to plan nothing."
  type        = bool
  default     = true
}

variable "location" {
  description = "Location of the repository: a region such as europe-west1 or a multi-region such as us."
  type        = string
}

variable "format" {
  description = "Repository format: DOCKER, NPM, PYTHON, MAVEN or GENERIC."
  type        = string
  default     = "DOCKER"
  validation {
    condition     = contains(["DOCKER", "NPM", "PYTHON", "MAVEN", "GENERIC"], var.format)
    error_message = "format must be one of DOCKER, NPM, PYTHON, MAVEN, GENERIC."
  }
}

variable "keep_last_versions" {
  description = "Number of most recent versions the cleanup policy always keeps."
  type        = number
  default     = 30
  validation {
    condition     = var.keep_last_versions >= 1 && var.keep_last_versions <= 1000 && var.keep_last_versions == floor(var.keep_last_versions)
    error_message = "keep_last_versions must be an integer between 1 and 1000."
  }
}

variable "reader_members" {
  description = "IAM members granted roles/artifactregistry.reader, each prefixed user:, serviceAccount:, group: or domain:."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for m in var.reader_members : can(regex("^(user|serviceAccount|group|domain):", m))])
    error_message = "Each reader member must start with user:, serviceAccount:, group: or domain:."
  }
}

variable "writer_members" {
  description = "IAM members granted roles/artifactregistry.writer, each prefixed user:, serviceAccount:, group: or domain:."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for m in var.writer_members : can(regex("^(user|serviceAccount|group|domain):", m))])
    error_message = "Each writer member must start with user:, serviceAccount:, group: or domain:."
  }
}

variable "kms_key_name" {
  description = "Cloud KMS crypto key (projects/.../cryptoKeys/...) used to encrypt the repository. Null uses Google-managed encryption."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels merged onto the repository, applied last."
  type        = map(string)
  default     = {}
}
