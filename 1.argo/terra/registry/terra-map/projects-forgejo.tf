resource "harbor_project" "forgejo-action" {
  name                        = "forgejo-action"
  public                      = "false"
  storage_quota               = 10
  auto_sbom_generation        = true
}
