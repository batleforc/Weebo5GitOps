resource "vault_policy" "harbor_policy" {
  name = "harbor_policy"

  policy = <<EOT
path "${vault_mount.main-vault.path}/+/+/harbor" {
  capabilities = ["create", "read", "update", "delete", "list","patch"]
}
path "${vault_mount.main-vault.path}/+/+/+/harbor" {
  capabilities = ["create", "read", "update", "delete", "list","patch"]
}
path "${vault_mount.main-vault.path}/metadata/harbor/harbor" {
  capabilities = ["create", "read", "update", "delete", "list","patch"]
}
path "${vault_mount.main-vault.path}/data/harbor/harbor" {
  capabilities = ["create", "read", "update", "delete", "list","patch"]
}
path "${vault_mount.main-vault.path}/data/{{identity.entity.aliases.${data.vault_auth_backend.kubernetes.accessor}.metadata.service_account_namespace}}/*" {
  capabilities = ["read","list"]
}
path "${vault_mount.main-vault.path}/data/{{identity.entity.aliases.${data.vault_auth_backend.kubernetes.accessor}.metadata.service_account_namespace}}/config" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "${vault_mount.main-vault.path}/data/{{identity.entity.aliases.${data.vault_auth_backend.kubernetes.accessor}.metadata.service_account_namespace}}/sub" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "${vault_mount.main-vault.path}/metadata/{{identity.entity.aliases.${data.vault_auth_backend.kubernetes.accessor}.metadata.service_account_namespace}}/sub" {
  capabilities = ["read","list"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "auth-harbor" {
  role_name                        = "auth-harbor"
  bound_service_account_names      = ["harbor", "default"]
  bound_service_account_namespaces = ["harbor"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.harbor_policy.name]
}
