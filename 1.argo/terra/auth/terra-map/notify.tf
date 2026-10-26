resource "random_password" "notify_attachments" {
  length  = 48
  special = true
}

resource "random_password" "notify_database" {
  length  = 32
  special = false
}

# Stable P-256 VAPID signing key for Web Push. The PKCS#8 form is written to
# Vault below; keep this resource in Terraform state so upgrades do not rotate
# the key and invalidate every browser subscription.
resource "tls_private_key" "notify_vapid" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "authentik_provider_oauth2" "notify" {
  name               = "weebo-notify"
  client_id          = "weebo-notify"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  client_type        = "public"
  # Authentik 2026.8 validates this list at /authorize. An empty list is not
  # equivalent to the OAuth defaults for providers created by Terraform.
  grant_types = [
    "authorization_code",
    "refresh_token",
  ]
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://notify.weebo.fr/auth/callback",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "notify" {
  name              = "weebo-notify"
  slug              = "weebo-notify"
  protocol_provider = authentik_provider_oauth2.notify.id
  meta_launch_url   = "https://notify.weebo.fr"
}

resource "vault_kv_secret_v2" "notify" {
  mount = "mv"
  name  = "notify/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID      = authentik_provider_oauth2.notify.client_id,
      AUTHENTIK_CLIENT_SECRET  = authentik_provider_oauth2.notify.client_secret,
      AUTHENTIK_URL            = "https://auth.batleforc.fr/application/o/${authentik_application.notify.slug}/",
      ATTACHMENTS_TOKEN_SECRET = random_password.notify_attachments.result,
      VAPID_PRIVATE_KEY        = tls_private_key.notify_vapid.private_key_pem_pkcs8,
      POSTGRES_USER            = "notify",
      POSTGRES_PASSWORD        = random_password.notify_database.result,
      DATABASE_URL             = "postgresql://notify:${random_password.notify_database.result}@notify-postgresql.notify.svc.cluster.local:5432/notify",
    }
  )
}

resource "authentik_policy_binding" "notify-access" {
  target = authentik_application.notify.uuid
  group  = authentik_group.weebo_user.id
  order  = 0
}
