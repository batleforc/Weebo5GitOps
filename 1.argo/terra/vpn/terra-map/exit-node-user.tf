resource "netbird_group" "exit-node-user" {
  name = "exit-node-user"
}

resource "netbird_setup_key" "exit-node-user" {
  name                   = "exit-node-user setup key"
  expiry_seconds         = 0 # 30 days
  type                   = "reusable"
  allow_extra_dns_labels = true
  auto_groups            = [netbird_group.exit-node-user.id]
  ephemeral              = true
  revoked                = false
  usage_limit            = 0
}

resource "netbird_route" "kubernetes-exit-node-v4" {
  network_id = "exit-node-user"
  #access_control_groups = [data.netbird_group.weebo_admin.id]
  groups      = [data.netbird_group.weebo_admin.id]
  peer_groups = [netbird_group.exit-node-user.id]
  description = "Kubernetes Exit Node Route"
  network     = "0.0.0.0/0"
}

resource "netbird_route" "kubernetes-exit-node-v6" {
  network_id = "exit-node-user"
  #access_control_groups = [data.netbird_group.weebo_admin.id]
  groups      = [data.netbird_group.weebo_admin.id]
  peer_groups = [netbird_group.exit-node-user.id]
  description = "Kubernetes Exit Node Route v6"
  network     = "::/0"
}

# Uncomment if you want to add IPv6 support for the exit node, at the moment netbird does not support IPv6 routes
# resource "netbird_route" "kubernetes-exit-node-ipv6" {
#   network_id = "exit-node-user"
#   #access_control_groups = [data.netbird_group.weebo_admin.id]
#   groups      = [data.netbird_group.weebo_admin.id]
#   peer_groups = [netbird_group.exit-node-user.id]
#   description = "Kubernetes Exit Node IPv6 Route"
#   network     = "::/0"
# }

resource "netbird_policy" "exit-node-user" {
  name    = "Exit Node User"
  enabled = true

  rule {
    action        = "accept"
    bidirectional = false
    enabled       = true
    protocol      = "all"
    name          = "exit-node-user"
    sources       = [data.netbird_group.weebo_user.id]
    destinations  = [netbird_group.exit-node-user.id]
  }
}


resource "vault_kv_secret_v2" "exit-node-user" {
  mount = "mv"
  name  = "exit-node-user/vpn-exit-node"
  data_json = jsonencode(
    {
      KUBERNETES_SETUP_KEY = netbird_setup_key.exit-node-user.key
    }
  )
}
