resource "netbird_group" "home-assistant" {
  name = "home-assistant"
}

resource "netbird_setup_key" "home-assistant" {
  name                   = "home-assistant setup key"
  expiry_seconds         = 0 # 30 days
  type                   = "reusable"
  allow_extra_dns_labels = true
  auto_groups            = [netbird_group.home-assistant.id]
  ephemeral              = false
  revoked                = false
  usage_limit            = 0
}

resource "netbird_policy" "home-assistant" {
  name    = "Home Assistant"
  enabled = true

  rule {
    action        = "accept"
    bidirectional = false
    enabled       = true
    protocol      = "all"
    name          = "home-assistant"
    sources       = [data.netbird_group.weebo_admin.id]
    destinations  = [netbird_group.home-assistant.id]
  }
}

resource "vault_kv_secret_v2" "home-assistant" {
  mount = "mv"
  name  = "reserved/vpn-exit-node"
  data_json = jsonencode(
    {
      KUBERNETES_SETUP_KEY = netbird_setup_key.home-assistant.key
    }
  )
}
