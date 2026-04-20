resource "authentik_group" "git_user" {
  name         = "git_user"
  is_superuser = false
}

resource "authentik_group" "git_restricted" {
  name         = "git_restricted"
  is_superuser = false
}

resource "authentik_provider_oauth2" "git" {
  name               = "git"
  client_id          = "git"
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://git.batleforc.fr/user/oauth2/batleforc-sso/callback",
    },
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    authentik_property_mapping_provider_scope.git.id,
  ]
}

# Create a scope mapping

resource "authentik_property_mapping_provider_scope" "git" {
  name       = "git"
  scope_name = "git"
  expression = <<EOF
forgejo_claims = {}

if request.user.groups.filter(name="${authentik_group.git_user.name}").exists() or request.user.groups.filter(name="${authentik_group.weebo_user.name}").exists() or request.user.groups.filter(name="${authentik_group.weebo_moderator.name}").exists():
    forgejo_claims["forgejo"]= "user"
if request.user.groups.filter(name="${authentik_group.weebo_admin.name}").exists():
    forgejo_claims["forgejo"]= "admin"
if request.user.groups.filter(name="${authentik_group.git_restricted.name}").exists():
    forgejo_claims["forgejo"]= "restricted"

return forgejo_claims
EOF
}

resource "authentik_application" "git" {
  name              = "git"
  slug              = "git"
  protocol_provider = authentik_provider_oauth2.git.id
}

resource "vault_kv_secret_v2" "git" {
  mount = "mv"
  name  = "git/auth"
  data_json = jsonencode(
    {
      AUTHENTIK_CLIENT_ID     = authentik_provider_oauth2.git.client_id,
      AUTHENTIK_CLIENT_SECRET = authentik_provider_oauth2.git.client_secret,
      AUTHENTIK_URL           = "https://auth.batleforc.fr/application/o/${authentik_application.git.slug}/",
      AUTHENTIK_SCOPE         = "openid profile email git",
    }
  )
}
