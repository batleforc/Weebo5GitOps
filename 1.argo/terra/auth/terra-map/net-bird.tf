# Value based from the authentik documentation:
# https://integrations.goauthentik.io/integrations/services/vpn/

resource "authentik_provider_oauth2" "vpn" {
  name               = "vpn"
  client_id          = "vpn"
  client_type        = "private"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://vpn.batleforc.fr",
    },
    {
      matching_mode = "strict",
      url           = "http://localhost:53000",
    },
    {
      matching_mode = "regex",
      url           = "https://vpn.batleforc.fr.*",
    }
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
    data.authentik_property_mapping_provider_scope.scope-api.id,
  ]
  include_claims_in_id_token = true
}

resource "random_password" "vpn_sa_password" {
  length           = 32
  special          = true
  override_special = "_-"
}

resource "authentik_user" "vpn_sa" {
  username = "vpn"
  type     = "service_account"
  groups   = [authentik_group.weebo_admin.id]
  password = random_password.vpn_sa_password.result
}

resource "authentik_token" "vpn_sa" {
  identifier   = "vpn"
  user         = authentik_user.vpn_sa.id
  description  = "My super token"
  retrieve_key = true
  intent       = "app_password"
  expiring     = false
}


resource "authentik_application" "vpn" {
  name              = "vpn"
  slug              = "vpn"
  protocol_provider = authentik_provider_oauth2.vpn.id
}

resource "random_string" "encryption_key" {
  length  = 32
  special = true
}

resource "random_password" "vpn_relay_password" {
  length           = 32
  special          = true
  override_special = "_-"
}

resource "vault_kv_secret_v2" "vpn" {
  mount = "mv"
  name  = "vpn/auth"
  data_json = jsonencode(
    {
      NETBIRD_AUTH_OIDC_CONFIGURATION_ENDPOINT = "https://auth.batleforc.fr/application/o/${authentik_application.vpn.slug}/.well-known/openid-configuration",
      NETBIRD_AUTH_BASE_URL                    = "https://auth.batleforc.fr/application/o/${authentik_application.vpn.slug}",
      NETBIRD_USE_AUTH0                        = "false",
      NETBIRD_AUTH_CLIENT_ID                   = authentik_provider_oauth2.vpn.client_id,
      NETBIRD_AUTH_SUPPORTED_SCOPES            = "openid profile email offline_access api",
      NETBIRD_AUTH_AUDIENCE                    = authentik_provider_oauth2.vpn.client_secret,
      NETBIRD_AUTH_CLIENT_SECRET               = authentik_provider_oauth2.vpn.client_secret,
      NETBIRD_AUTH_DEVICE_AUTH_CLIENT_ID       = authentik_provider_oauth2.vpn.client_id,
      NETBIRD_AUTH_DEVICE_AUTH_AUDIENCE        = authentik_provider_oauth2.vpn.client_id,
      NETBIRD_MGMT_IDP                         = "authentik",
      NETBIRD_IDP_MGMT_CLIENT_ID               = authentik_provider_oauth2.vpn.client_id,
      NETBIRD_IDP_MGMT_EXTRA_USERNAME          = authentik_user.vpn_sa.username,
      NETBIRD_IDP_MGMT_EXTRA_PASSWORD          = authentik_token.vpn_sa.key,
      NETBIRD_DATASTORE_ENCRYPTION_KEY         = base64encode(random_string.encryption_key.result),
      NETBIRD_REPLAY_PASSWORD                  = random_password.vpn_relay_password.result,
    }
  )
}
