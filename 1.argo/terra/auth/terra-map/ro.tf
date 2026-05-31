resource "authentik_provider_oauth2" "ro" {
  name               = "romm"
  client_id          = "ro"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://ro.weebo.fr/api/oauth/openid",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "ro" {
  name              = "ro"
  slug              = "ro"
  protocol_provider = authentik_provider_oauth2.ro.id
}

resource "vault_kv_secret_v2" "ro" {
  mount = "mv"
  name  = "ro/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID     = authentik_provider_oauth2.ro.client_id,
      AUTHENTIK_CLIENT_SECRET = authentik_provider_oauth2.ro.client_secret,
      AUTHENTIK_URL           = "https://auth.batleforc.fr/application/o/${authentik_application.ro.slug}/",
    }
  )
}

resource "authentik_policy_binding" "ro-access" {
  target = authentik_application.ro.uuid
  group  = authentik_group.weebo_admin.id
  order  = 0
}
