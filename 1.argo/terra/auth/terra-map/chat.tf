resource "authentik_provider_oauth2" "chat" {
  name               = "chat"
  client_id          = "chat"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://chat.batleforc.fr/_matrix/client/unstable/login/sso/callback/chat",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "chat" {
  name              = "chat"
  slug              = "chat"
  protocol_provider = authentik_provider_oauth2.chat.id
}

resource "vault_kv_secret_v2" "chat" {
  mount = "mv"
  name  = "chat/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID     = authentik_provider_oauth2.chat.client_id,
      AUTHENTIK_CLIENT_SECRET = authentik_provider_oauth2.chat.client_secret,
      AUTHENTIK_URL           = "https://auth.batleforc.fr/application/o/${authentik_application.chat.slug}/",
    }
  )
}
