# weebo-kura (Obsidian sync). Three public clients sharing one issuer: the
# providers run in global issuer mode, so kura-server's oidc.issuer is
# https://auth.batleforc.fr/. Device code uses the brand's device-code-flow
# (flow.tf). `groups` comes from the profile scope; it must also be in the
# access token, hence include_claims_in_id_token.

locals {
  kura_device_clients = {
    "kura-cli"    = "weebo-kura CLI"
    "kura-plugin" = "weebo-kura Obsidian plugin"
  }
}

resource "authentik_provider_oauth2" "kura_device" {
  for_each                   = local.kura_device_clients
  name                       = each.key
  client_id                  = each.key
  client_type                = "public"
  issuer_mode                = "global"
  include_claims_in_id_token = true
  # A device code must outlive the time it takes to type it on a phone.
  access_code_validity = "minutes=10"
  invalidation_flow    = data.authentik_flow.default-invalidation-flow.id
  authorization_flow   = data.authentik_flow.default-authorization-flow.id
  signing_key          = data.authentik_certificate_key_pair.generated.id
  grant_types = [
    "urn:ietf:params:oauth:grant-type:device_code",
    "refresh_token",
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "kura_device" {
  for_each          = local.kura_device_clients
  name              = each.value
  slug              = each.key
  protocol_provider = authentik_provider_oauth2.kura_device[each.key].id
  meta_launch_url   = "blank://blank"
}

# The web console, served by kura-server under /app.
resource "authentik_provider_oauth2" "kura_web" {
  name                       = "kura-web"
  client_id                  = "kura-web"
  client_type                = "public"
  issuer_mode                = "global"
  include_claims_in_id_token = true
  invalidation_flow          = data.authentik_flow.default-invalidation-flow.id
  authorization_flow         = data.authentik_flow.default-authorization-flow.id
  signing_key                = data.authentik_certificate_key_pair.generated.id
  grant_types = [
    "authorization_code",
    "refresh_token",
  ]
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://kura.weebo.fr/app/callback",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline.id,
  ]
}

resource "authentik_application" "kura_web" {
  name              = "weebo-kura"
  slug              = "kura-web"
  protocol_provider = authentik_provider_oauth2.kura_web.id
  meta_launch_url   = "https://kura.weebo.fr/app"
}

# Tenant roles map weebo_admin only (1.helm/kura documents); widen both
# together.
resource "authentik_policy_binding" "kura-access" {
  for_each = merge(
    { for k, a in authentik_application.kura_device : k => a.uuid },
    { "kura-web" = authentik_application.kura_web.uuid },
  )
  target = each.value
  group  = authentik_group.weebo_admin.id
  order  = 0
}
