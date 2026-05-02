resource "authentik_provider_oauth2" "guard" {
  name               = "guard"
  client_id          = "guard"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://guard.batleforc.fr/identity/connect/oidc-signin",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "guard" {
  name              = "guard"
  slug              = "guard"
  protocol_provider = authentik_provider_oauth2.guard.id
}

resource "vault_kv_secret_v2" "guard" {
  mount = "mv"
  name  = "guard/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID     = authentik_provider_oauth2.guard.client_id,
      AUTHENTIK_CLIENT_SECRET = authentik_provider_oauth2.guard.client_secret,
      AUTHENTIK_URL           = "https://auth.batleforc.fr/application/o/${authentik_application.guard.slug}/",
    }
  )
}
