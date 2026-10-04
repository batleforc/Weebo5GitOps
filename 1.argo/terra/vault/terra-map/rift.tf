# Rift of Sym hub/runner secrets, synced into the risym namespace by an ExternalSecret.
resource "random_password" "RIFT_SERVER_TOKEN" {
  length  = 64
  special = false
}

resource "random_password" "RIFT_OPS_TOKEN" {
  length  = 64
  special = false
}

# netcode's private key: exactly 64 hex characters.
resource "random_id" "RIFT_NETCODE_KEY" {
  byte_length = 32
}

# Goes into a postgres:// URL, so no special characters.
resource "random_password" "RIFT_POSTGRES_PASSWORD" {
  length  = 42
  special = false
}

resource "vault_kv_secret_v2" "rift" {
  mount = vault_mount.main-vault.path
  name  = "risym/config"
  data_json = jsonencode(
    {
      RIFT_SERVER_TOKEN = random_password.RIFT_SERVER_TOKEN.result,
      HUB_OPS_TOKEN     = random_password.RIFT_OPS_TOKEN.result,
      RIFT_NETCODE_KEY  = random_id.RIFT_NETCODE_KEY.hex,
      POSTGRES_PASSWORD = random_password.RIFT_POSTGRES_PASSWORD.result,
    }
  )
}
