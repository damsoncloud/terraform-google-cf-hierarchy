resource "google_tags_tag_key" "environment" {
  parent      = local.organization
  short_name  = "environment"
  description = "Environment of the resources."
}

resource "google_tags_tag_value" "environments" {
  for_each = local.folders

  parent      = google_tags_tag_key.environment.id
  short_name  = each.key
  description = "${title(each.key)} environment."
}

resource "google_tags_tag_binding" "environments" {
  for_each = local.folders

  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.environments[each.key].name}"
  tag_value = google_tags_tag_value.environments[each.key].id
}
