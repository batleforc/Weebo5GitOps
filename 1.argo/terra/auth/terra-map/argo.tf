resource "authentik_provider_oauth2" "argo" {
  name               = "argo"
  client_id          = "argo"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://argo.batleforc.fr/api/dex/callback",
    },
    {
      matching_mode = "strict",
      url           = "https://localhost:8085/auth/callback",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "argo" {
  name              = "argo"
  slug              = "argo"
  protocol_provider = authentik_provider_oauth2.argo.id
}

resource "vault_kv_secret_v2" "argo" {
  mount = "mv"
  name  = "argocd/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID     = authentik_provider_oauth2.argo.client_id,
      AUTHENTIK_CLIENT_SECRET = authentik_provider_oauth2.argo.client_secret,
      AUTHENTIK_URL           = "https://auth.batleforc.fr/application/o/${authentik_application.argo.slug}/",
    }
  )
}
