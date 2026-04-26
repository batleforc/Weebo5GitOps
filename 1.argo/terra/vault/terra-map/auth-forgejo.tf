resource "vault_mount" "git_vault" {
  path        = "git-vault"
  type        = "kv"
  options     = { version = "2" }
  description = "Vault for Git repositories secrets"
}

resource "vault_jwt_auth_backend" "forgejo_auth" {
  description        = "Forgejo JWT Auth Backend"
  path               = "forgejo_jwt"
  oidc_discovery_url = "https://git.batleforc.fr/api/actions"
  bound_issuer       = "https://git.batleforc.fr/"
}

resource "vault_policy" "forgejo_default_policy" {
  name = "forgejo_default_policy"

  policy = <<EOT
path "${vault_mount.git_vault.path}/data/{{identity.entity.aliases.${vault_jwt_auth_backend.forgejo_auth.accessor}.metadata.repository}}/default" {
  capabilities = ["read","list"]
}
path "${vault_mount.git_vault.path}/metadata/{{identity.entity.aliases.${vault_jwt_auth_backend.forgejo_auth.accessor}.metadata.repository}}/default" {
  capabilities = ["read","list"]
}
path "${vault_mount.git_vault.path}/data/{{identity.entity.aliases.${vault_jwt_auth_backend.forgejo_auth.accessor}.metadata.repository}}/registry" {
  capabilities = ["read","list"]
}
path "${vault_mount.git_vault.path}/metadata/{{identity.entity.aliases.${vault_jwt_auth_backend.forgejo_auth.accessor}.metadata.repository}}/registry" {
  capabilities = ["read","list"]
}

EOT
}

resource "vault_jwt_auth_backend_role" "forgejo_role" {
  backend        = vault_jwt_auth_backend.forgejo_auth.path
  role_name      = "forgejo_action"
  token_policies = [vault_policy.forgejo_default_policy.name]

  bound_audiences = ["forgejo_action"]
  bound_claims = {
    ref = "refs/heads/main"
    #sub = "repo:batleforc/*"
  }
  bound_claims_type = "glob"
  user_claim        = "repository"
  role_type         = "jwt"
}
