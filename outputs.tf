output "folders" {
  description = "Resource names of the folders (`folders/<id>`), by folder name."
  value       = { for name, folder in google_folder.environments : name => folder.name }
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
