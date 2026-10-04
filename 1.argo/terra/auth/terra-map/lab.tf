resource "authentik_provider_oauth2" "lab" {
  name               = "lab"
  client_id          = "lab"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://dex.4.weebo.fr/dex/callback",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "lab" {
  name              = "lab"
  slug              = "lab"
  protocol_provider = authentik_provider_oauth2.lab.id
  meta_launch_url   = "https://4.weebo.fr"
}

resource "vault_kv_secret_v2" "lab" {
  mount = "mv"
  name  = "lab-reserved/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID     = authentik_provider_oauth2.lab.client_id,
      AUTHENTIK_CLIENT_SECRET = authentik_provider_oauth2.lab.client_secret,
      AUTHENTIK_URL           = "https://auth.batleforc.fr/application/o/${authentik_application.chat.slug}/",
    }
  )
}

resource "authentik_policy_binding" "lab-access" {
  target = authentik_application.lab.uuid
  group  = authentik_group.weebo_moderator.id
  order  = 0
}
