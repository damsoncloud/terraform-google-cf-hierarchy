locals {
  organization = "organizations/${var.organization_id}"
  folders      = toset(concat(var.environments, var.create_legacy_folder ? ["legacy"] : []))
}

resource "google_folder" "environments" {
  for_each = local.folders

  display_name = each.key
  parent       = local.organization
}
