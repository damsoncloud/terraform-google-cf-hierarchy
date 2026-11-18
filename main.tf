locals {
  organization     = "organizations/${var.organization_id}"
  all_environments = merge(var.environments, var.common_environment)
  folders          = toset(concat(keys(local.all_environments), var.create_legacy_folder ? ["legacy"] : []))
}

resource "google_folder" "environments" {
  for_each = local.folders

  display_name = each.key
  parent       = local.organization
}
