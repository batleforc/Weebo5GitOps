# weebo-kura (weebo5GitOpsInternal: 1.helm/kura). kura-server logs in with
# its ServiceAccount `kura`, reads its database URL and bucket from KV, and
# wraps each tenant's data keys with the Transit key `kura-<tenant>`.

resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "Transit (envelope encryption): weebo-kura"
}

# One key per KuraTenant, created before its first upload. kura-server never
# creates, rotates or deletes keys. Never remove one from this list: the
# tenant's notes, and every backup of them, would be lost with it.
locals {
  kura_tenants = ["max"]
}

resource "vault_transit_secret_backend_key" "kura" {
  for_each         = toset(local.kura_tenants)
  backend          = vault_mount.transit.path
  name             = "kura-${each.key}"
  type             = "aes256-gcm96"
  deletion_allowed = false
}

# deploy/vault/kura-server.hcl. The bucket lives at mv/kura/s3 rather than
# upstream's mv/kura/bucket: the s3 terraform role may only write mv/+/s3.
resource "vault_policy" "kura_server" {
  name   = "kura-server"
  policy = <<EOT
path "${vault_mount.main-vault.path}/data/kura/database" {
  capabilities = ["read"]
}
path "${vault_mount.main-vault.path}/data/kura/s3" {
  capabilities = ["read"]
}
path "${vault_mount.transit.path}/datakey/plaintext/kura-*" {
  capabilities = ["update"]
}
path "${vault_mount.transit.path}/decrypt/kura-*" {
  capabilities = ["update"]
}
path "${vault_mount.transit.path}/rewrap/kura-*" {
  capabilities = ["update"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "kura" {
  role_name                        = "kura"
  bound_service_account_names      = ["kura"]
  bound_service_account_namespaces = ["kura"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.kura_server.name]
}

# kura's own PostgreSQL (weebo5GitOpsInternal: 1.helm/kura/templates/
# postgresql.yaml). Its first start creates kura_owner and kura_app with these
# passwords. Init scripts only run on an empty volume: after a rotation here,
# ALTER ROLE by hand. No special characters: they go into postgres:// URLs.
resource "random_password" "kura_postgres" {
  length  = 42
  special = false
}
resource "random_password" "kura_owner" {
  length  = 42
  special = false
}
resource "random_password" "kura_app" {
  length  = 42
  special = false
}

# Read by kura-server only (policy kura-server): kura_app's URL.
resource "vault_kv_secret_v2" "kura_database" {
  mount = vault_mount.main-vault.path
  name  = "kura/database"
  data_json = jsonencode(
    {
      url = "postgres://kura_app:${random_password.kura_app.result}@kura-postgresql.kura.svc:5432/kura",
    }
  )
}

# Read by ESO in the kura namespace (auth-read): the database container and
# the migration Job.
resource "vault_kv_secret_v2" "kura_postgres" {
  mount = vault_mount.main-vault.path
  name  = "kura/postgres"
  data_json = jsonencode(
    {
      POSTGRES_PASSWORD   = random_password.kura_postgres.result,
      KURA_OWNER_PASSWORD = random_password.kura_owner.result,
      KURA_APP_PASSWORD   = random_password.kura_app.result,
      OWNER_URL           = "postgres://kura_owner:${random_password.kura_owner.result}@kura-postgresql.kura.svc:5432/kura",
    }
  )
}
