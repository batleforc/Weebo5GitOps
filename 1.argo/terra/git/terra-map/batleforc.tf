resource "forgejo_repository" "Weebo5GitOps" {
  name        = "Weebo5GitOps"
  description = "Repo for the Weebo5 GitOps"
  auto_init   = false
}



resource "forgejo_repository" "monofolio-rs" {
  name        = "monofolio-rs"
  description = "Portfolio website for batleforc.fr, built with Rust and Leptos"
  auto_init   = false
}
