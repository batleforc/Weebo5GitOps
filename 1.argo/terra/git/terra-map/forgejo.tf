resource "forgejo_organization" "forgejo" {
  name = "forgejo"
}

resource "forgejo_repository" "buildah" {
  owner       = forgejo_organization.forgejo.name
  name        = "buildah"
  description = "Repo for the buildah base image used in CI pipelines"
}
