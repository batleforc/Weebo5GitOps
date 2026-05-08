resource "forgejo_organization" "forgejo" {
  name = "forgejo"
}

resource "forgejo_repository" "buildah" {
  owner       = forgejo_organization.forgejo.name
  name        = "buildah"
  description = "Repo for the buildah base image used in CI pipelines"
}

resource "forgejo_repository" "runner" {
  owner       = forgejo_organization.forgejo.name
  name        = "runner"
  description = "Repo for the runner used in CI pipelines"
}
