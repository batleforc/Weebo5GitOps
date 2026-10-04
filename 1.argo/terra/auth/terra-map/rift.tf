resource "authentik_provider_oauth2" "rift" {
  name               = "rift-of-sym"
  client_id          = "rift-of-sym"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  # RS256: the hub pins it and refuses to start against an empty JWKS (HS256).
  signing_key = data.authentik_certificate_key_pair.generated.id
  # A game client cannot keep a secret: device code + PKCE.
  client_type = "public"
  allowed_redirect_uris = [
    {
      # The launcher's browser sign-in, on any loopback port. No `:` and no `[...]`:
      # Authentik urlparses every redirect URI to build CORS origins, and `[0-9]` reads
      # as a broken IPv6 host — every request carrying an Origin then 500s.
      matching_mode = "regex",
      url           = "http://127\\.0\\.0\\.1\\x3a\\d+/callback",
    },
    {
      # The CORS origin for the website: regex entries never match one.
      matching_mode = "strict",
      url           = "https://rift.game.weebo.fr/",
    },
    {
      # The website's sign-in (location.origin + pathname).
      matching_mode = "regex",
      url           = "https://rift\\.game\\.weebo\\.fr/.*",
    },
  ]
  # The `groups` claim (hub admin view) comes with the profile scope.
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "rift" {
  name              = "Rift of Sym"
  slug              = "rift-of-sym"
  protocol_provider = authentik_provider_oauth2.rift.id
  meta_launch_url   = "https://rift.game.weebo.fr"
}

# Read by the risym namespace (mv_reader_policy scopes reads to mv/<namespace>/*).
resource "vault_kv_secret_v2" "rift" {
  mount = "mv"
  name  = "risym/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID = authentik_provider_oauth2.rift.client_id,
      AUTHENTIK_URL       = "https://auth.batleforc.fr/application/o/${authentik_application.rift.slug}/",
    }
  )
}

resource "authentik_policy_binding" "rift-access" {
  target = authentik_application.rift.uuid
  group  = authentik_group.weebo_user.id
  order  = 0
}
