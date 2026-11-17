variable "organization_id" {
  description = "ID of the organisation, the parent of the folders and the `environment` tag key."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.organization_id))
    error_message = "The organization_id must be the numeric organisation ID."
  }
}

variable "environments" {
  description = "Names of the environment folders, also used as the folders' display names."
  type        = list(string)
  default     = ["development", "certification", "production", "common"]

  validation {
    condition     = length(var.environments) == length(distinct(var.environments))
    error_message = "The environments must be unique."
  }

  validation {
    condition     = alltrue([for environment in var.environments : can(regex("^[a-z][a-z0-9-]{0,28}[a-z0-9]$", environment))])
    error_message = "Each environment must be 2-30 lowercase letters, digits or hyphens, starting with a letter and not ending with a hyphen."
  }

  validation {
    condition     = !contains(var.environments, "legacy")
    error_message = "The legacy folder is controlled by create_legacy_folder, not by the environments."
  }
}

variable "create_legacy_folder" {
  description = "Whether to create the `legacy` folder, holding the organisation's existing projects and folders."
  type        = bool
  default     = true
}
