data "vault_kv_secret_v2" "authentik" {
  mount = "mv"
  name  = "vpn/auth"
}

resource "netbird_identity_provider" "authentik" {
  name          = "Batleforc SSO"
  type          = "oidc"
  client_id     = data.vault_kv_secret_v2.authentik.data["NETBIRD_AUTH_CLIENT_ID"]
  client_secret = data.vault_kv_secret_v2.authentik.data["NETBIRD_AUTH_CLIENT_SECRET"]
  issuer        = data.vault_kv_secret_v2.authentik.data["NETBIRD_AUTH_BASE_URL"]
}
