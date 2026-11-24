variable "organization_id" {
  description = "ID of the organisation, the parent of the folders and the `environment` tag key."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.organization_id))
    error_message = "The organization_id must be the numeric organisation ID."
  }
}

variable "environments" {
  description = <<-EOT
  Short names of the environments other than the common one, by folder name.
  The names are also the folders' display names; the short names are returned with the folders, e.g. for the names of the environments' groups and resources.
  EOT
  type        = map(string)
  default = {
    development   = "dev"
    certification = "cert"
    production    = "prod"
  }
  nullable = false

  validation {
    condition     = alltrue([for environment in keys(var.environments) : can(regex("^[a-z][a-z0-9-]{0,28}[a-z0-9]$", environment))])
    error_message = "Each environment must be 2-30 lowercase letters, digits or hyphens, starting with a letter and not ending with a hyphen."
  }

  validation {
    condition     = alltrue([for short_name in values(var.environments) : can(regex("^[a-z][a-z0-9-]{1,25}[a-z0-9]$", short_name))])
    error_message = "Each short name must be 3-27 lowercase letters, digits or hyphens, starting with a letter and not ending with a hyphen."
  }

  validation {
    condition     = !contains(keys(var.environments), "legacy")
    error_message = "The legacy folder is controlled by create_legacy_folder, not by the environments."
  }
}

variable "common_environment" {
  description = "Short name of the common environment, by folder name, e.g. holding the foundations' projects."
  type        = map(string)
  default = {
    common = "cmn"
  }
  nullable = false

  validation {
    condition     = length(var.common_environment) == 1
    error_message = "The common_environment must contain exactly one environment."
  }

  validation {
    condition = alltrue([for environment, short_name in var.common_environment :
      can(regex("^[a-z][a-z0-9-]{0,28}[a-z0-9]$", environment)) && can(regex("^[a-z][a-z0-9-]{1,25}[a-z0-9]$", short_name))
    ])
    error_message = "The common environment must be 2-30 and its short name 3-27 lowercase letters, digits or hyphens, starting with a letter and not ending with a hyphen."
  }

  validation {
    condition     = !contains(keys(var.common_environment), "legacy")
    error_message = "The legacy folder is controlled by create_legacy_folder, not by the common_environment."
  }

  validation {
    condition     = length(setintersection(keys(var.environments), keys(var.common_environment))) == 0
    error_message = "The common environment must not be one of the environments."
  }

  validation {
    condition     = length(distinct(concat(values(var.environments), values(var.common_environment)))) == length(var.environments) + length(var.common_environment)
    error_message = "The short names of the environments and the common environment must be unique."
  }
}

variable "create_legacy_folder" {
  description = "Whether to create the `legacy` folder, holding the organisation's existing projects and folders."
  type        = bool
  default     = true
}
