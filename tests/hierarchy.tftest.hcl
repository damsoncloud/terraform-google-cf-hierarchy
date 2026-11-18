mock_provider "google" {
  mock_resource "google_folder" {
    defaults = {
      name = "folders/111111111111"
    }
  }

  mock_resource "google_tags_tag_key" {
    defaults = {
      id              = "tagKeys/222222222222"
      namespaced_name = "123456789012/environment"
    }
  }

  mock_resource "google_tags_tag_value" {
    defaults = {
      id = "tagValues/333333333333"
    }
  }
}

variables {
  organization_id = "123456789012"
}

run "default_folders" {
  command = plan

  assert {
    condition     = keys(google_folder.environments) == ["certification", "common", "development", "legacy", "production"]
    error_message = "The default environments and the legacy folder must be created."
  }

  assert {
    condition     = alltrue([for name, folder in google_folder.environments : folder.display_name == name && folder.parent == "organizations/123456789012"])
    error_message = "Each folder must be named after its key and created in the organisation."
  }
}

run "default_tags" {
  command = plan

  assert {
    condition     = google_tags_tag_key.environment.short_name == "environment" && google_tags_tag_key.environment.parent == "organizations/123456789012"
    error_message = "The environment tag key must be created in the organisation."
  }

  assert {
    condition     = alltrue([for name, value in google_tags_tag_value.environments : value.short_name == name])
    error_message = "Each tag value must be named after its folder."
  }

  assert {
    condition     = keys(google_tags_tag_value.environments) == keys(google_folder.environments)
    error_message = "Each folder, including legacy, must have a tag value."
  }

  assert {
    condition     = keys(google_tags_tag_binding.environments) == keys(google_folder.environments)
    error_message = "Each folder, including legacy, must have a tag binding."
  }
}

run "without_legacy_folder" {
  command = plan

  variables {
    create_legacy_folder = false
  }

  assert {
    condition     = keys(google_folder.environments) == ["certification", "common", "development", "production"]
    error_message = "The legacy folder must not be created."
  }

  assert {
    condition     = keys(google_tags_tag_value.environments) == keys(google_folder.environments) && keys(google_tags_tag_binding.environments) == keys(google_folder.environments)
    error_message = "The legacy tag value and binding must not be created."
  }
}

run "custom_environments" {
  command = plan

  variables {
    environments = {
      dev  = "dev"
      prod = "prod"
    }
    common_environment = {
      shared = "shr"
    }
  }

  assert {
    condition     = keys(google_folder.environments) == ["dev", "legacy", "prod", "shared"]
    error_message = "Only the given environments, the common environment and the legacy folder must be created."
  }
}

run "bindings_and_outputs" {
  assert {
    condition = alltrue([for name, binding in google_tags_tag_binding.environments :
      binding.parent == "//cloudresourcemanager.googleapis.com/folders/111111111111" && binding.tag_value == "tagValues/333333333333"
    ])
    error_message = "Each folder must be bound to its tag value."
  }

  assert {
    condition     = alltrue([for value in google_tags_tag_value.environments : value.parent == "tagKeys/222222222222"])
    error_message = "Each tag value must belong to the environment tag key."
  }

  assert {
    # Compared as JSON, as the expected object's null short name has no type
    condition = jsonencode(output.folders) == jsonencode({
      development   = { id = "folders/111111111111", short_name = "dev", common = false }
      certification = { id = "folders/111111111111", short_name = "cert", common = false }
      production    = { id = "folders/111111111111", short_name = "prod", common = false }
      common        = { id = "folders/111111111111", short_name = "cmn", common = true }
      legacy        = { id = "folders/111111111111", short_name = null, common = false }
    })
    error_message = "The folders output must return each folder's resource name, short name and whether it is the common environment."
  }

  assert {
    condition     = output.environment_tag_key == "tagKeys/222222222222" && output.environment_tag_key_namespaced_name == "123456789012/environment"
    error_message = "The tag key outputs must return the key's ID and namespaced name."
  }

  assert {
    condition     = output.environment_tag_values == { for name in keys(google_folder.environments) : name => "tagValues/333333333333" }
    error_message = "The environment_tag_values output must map each folder name to its tag value ID."
  }
}

run "invalid_organization_id" {
  command = plan

  variables {
    organization_id = "organizations/123456789012"
  }

  expect_failures = [var.organization_id]
}

run "invalid_environment_name" {
  command = plan

  variables {
    environments = {
      Production = "prod"
    }
  }

  expect_failures = [var.environments]
}

run "invalid_short_name" {
  command = plan

  variables {
    environments = {
      production = "p"
    }
  }

  expect_failures = [var.environments]
}

run "legacy_as_environment" {
  command = plan

  variables {
    environments = {
      legacy = "leg"
    }
  }

  expect_failures = [var.environments]
}

run "several_common_environments" {
  command = plan

  variables {
    environments = {
      development = "dev"
    }
    common_environment = {
      common = "cmn"
      shared = "shr"
    }
  }

  expect_failures = [var.common_environment]
}

run "invalid_common_short_name" {
  command = plan

  variables {
    common_environment = {
      common = "c"
    }
  }

  expect_failures = [var.common_environment]
}

run "legacy_as_common_environment" {
  command = plan

  variables {
    common_environment = {
      legacy = "leg"
    }
  }

  expect_failures = [var.common_environment]
}

run "common_environment_in_environments" {
  command = plan

  variables {
    environments = {
      development = "dev"
      common      = "cmn"
    }
  }

  expect_failures = [var.common_environment]
}

run "duplicate_short_names" {
  command = plan

  variables {
    environments = {
      development = "dev"
      demo        = "cmn"
    }
  }

  expect_failures = [var.common_environment]
}
