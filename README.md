# Damson Cloud GCP Cloud Foundations: resource hierarchy

Terraform module of the Damson Cloud GCP Cloud Foundations creating the resource hierarchy of a Google Cloud organisation:

* the environment folders, and the `common` and `legacy` folders,
* the `environment` tag key, its values and their bindings to the folders.

The module is applied in the same Terraform state as [`cf-bootstrap`](https://registry.terraform.io/modules/damsoncloud/cf-bootstrap/google).

## Usage

```hcl
module "hierarchy" {
  source  = "damsoncloud/cf-hierarchy/google"
  version = "X.Y.Z"

  organization_id = "123456789012"
}
```

Pin an exact version. New versions are published as immutable GitHub releases with `vX.Y.Z` tags, following [semantic versioning](https://semver.org/).

See [`examples/basic`](examples/basic) for a complete example.

<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| common\_environment | Short name of the common environment, by folder name, e.g. holding the foundations' projects. | `map(string)` | ```{ "common": "cmn" }``` | no |
| create\_legacy\_folder | Whether to create the `legacy` folder, holding the organisation's existing projects and folders. | `bool` | `true` | no |
| environments | Short names of the environments other than the common one, by folder name. The names are also the folders' display names; the short names are returned with the folders, e.g. for the names of the environments' groups and resources. | `map(string)` | ```{ "certification": "cert", "development": "dev", "production": "prod" }``` | no |
| organization\_id | ID of the organisation, the parent of the folders and the `environment` tag key. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| environment\_tag\_key | ID of the `environment` tag key (`tagKeys/<id>`). |
| environment\_tag\_key\_namespaced\_name | Namespaced name of the `environment` tag key (`<organization_id>/environment`), e.g. for `resource.matchTag()` in IAM conditions. |
| environment\_tag\_values | IDs of the `environment` tag values (`tagValues/<id>`), by folder name. |
| folders | The folders by folder name:   `id`, the resource name (`folders/<id>`);   `short_name`, the environment's short name, null for `legacy`;   `common`, whether it is the common environment. |
<!-- markdownlint-restore -->
<!-- END_TF_DOCS -->

## Releases

Releases are dispatched manually on `main` with the [`release.yaml`](.github/workflows/release.yaml) workflow, choosing the part of the version to increase. It calls the
[`github-release.yaml`](https://github.com/damsoncloud/dcp.sdlc#reusable-workflows) reusable workflow, which creates the GitHub release and its tag. The Terraform Registry
publishes the new version from the tag.

## Security

See [SECURITY.md](SECURITY.md) for how to report vulnerabilities.

## Development

The repository uses [devenv](https://devenv.sh) with the shared [devenvbase](https://github.com/damsoncloud/dcp.sdlc/blob/main/devenvbase/README.md), pinned to a
[dcp.sdlc](https://github.com/damsoncloud/dcp.sdlc) release in `devenv.yaml`.

* `devenv shell` starts the shell.
* `devenv test` runs the git hooks and tests.
* `terraform_docs` regenerates the inputs and outputs above, which the `terraform-docs` git hook also does on commit.

The weekly `dcp.sdlc check` workflow opens an issue when a newer dcp.sdlc release is available. Upgrade with `devenv shell -- dcp_sdlc_upgrade_pr`, which also updates
the devenv inputs, runs the tests and opens a pull request.

## Licence

[Apache License 2.0](LICENSE)
