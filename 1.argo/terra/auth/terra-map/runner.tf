resource "authentik_provider_oauth2" "weebo-runner" {
  name               = "weebo-runner"
  client_id          = "weebo-runner"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://wr.batleforc.fr/callback",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "weebo-runner" {
  name              = "weebo-runner"
  slug              = "weebo-runner"
  protocol_provider = authentik_provider_oauth2.weebo-runner.id
  meta_launch_url   = "https://wr.batleforc.fr"
}

resource "vault_kv_secret_v2" "weebo-runner" {
  mount = "mv"
  name  = "weebo-runner/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID     = authentik_provider_oauth2.weebo-runner.client_id,
      AUTHENTIK_CLIENT_SECRET = authentik_provider_oauth2.weebo-runner.client_secret,
      AUTHENTIK_URL           = "https://auth.batleforc.fr/application/o/${authentik_application.weebo-runner.slug}/",
    }
  )
}

resource "authentik_policy_binding" "weebo-runner-access" {
  target = authentik_application.weebo-runner.uuid
  group  = authentik_group.weebo_partner.id
  order  = 0
}
