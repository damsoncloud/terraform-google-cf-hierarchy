output "folders" {
  description = "The folders by folder name: `id`, the resource name (`folders/<id>`); `short_name`, the environment's short name, null for `legacy`; `common`, whether it is the common environment."
  value = { for name, folder in google_folder.environments : name => {
    id         = folder.name
    short_name = lookup(local.all_environments, name, null)
    common     = contains(keys(var.common_environment), name)
  } }
}

output "environment_tag_key" {
  description = "ID of the `environment` tag key (`tagKeys/<id>`)."
  value       = google_tags_tag_key.environment.id
}

output "environment_tag_key_namespaced_name" {
  description = "Namespaced name of the `environment` tag key (`<organization_id>/environment`), e.g. for `resource.matchTag()` in IAM conditions."
  value       = google_tags_tag_key.environment.namespaced_name
}

output "environment_tag_values" {
  description = "IDs of the `environment` tag values (`tagValues/<id>`), by folder name."
  value       = { for name, value in google_tags_tag_value.environments : name => value.id }
}
