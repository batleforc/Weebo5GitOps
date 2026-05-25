resource "forgejo_organization" "action" {
  name = "action"
}

resource "forgejo_repository" "checkout" {
  owner           = forgejo_organization.action.name
  name            = "checkout"
  clone_addr      = "https://github.com/actions/checkout"
  mirror          = true
  mirror_interval = "12h0m0s" # optional
}

resource "forgejo_repository" "hashicorp_vault-action" {
  owner           = forgejo_organization.action.name
  name            = "hashicorp_vault-action"
  clone_addr      = "https://github.com/hashicorp/vault-action"
  mirror          = true
  mirror_interval = "12h0m0s" # optional
}

resource "forgejo_repository" "updatecli" {
  owner           = forgejo_organization.action.name
  name            = "updatecli"
  clone_addr      = "https://github.com/updatecli/updatecli-action"
  mirror          = true
  mirror_interval = "12h0m0s" # optional
}

resource "forgejo_repository" "rust-toolchain" {
  owner           = forgejo_organization.action.name
  name            = "rust-toolchain"
  clone_addr      = "https://github.com/dtolnay/rust-toolchain"
  mirror          = true
  mirror_interval = "12h0m0s" # optional
}

resource "forgejo_repository" "git-pages" {
  owner           = forgejo_organization.action.name
  name            = "git-pages"
  clone_addr      = "https://codeberg.org/git-pages/action"
  mirror          = true
  mirror_interval = "12h0m0s" # optional
}
