resource "vault_mount" "dev-vault" {
  path        = "dv"
  type        = "kv"
  options     = { version = "2" }
  description = "Dev dedicated vault"
}

resource "vault_kv_secret_backend_v2" "dev-vault" {
  mount = vault_mount.dev-vault.path
}
