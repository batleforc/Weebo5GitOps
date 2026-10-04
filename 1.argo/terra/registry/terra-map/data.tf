ephemeral "vault_kv_secret_v2" "harbor_config" {
  mount = "mv"
  name  = "registry/config"
}

data "vault_kv_secret_v2" "harbor_auth" {
  mount = "mv"
  name  = "registry/auth"
}
