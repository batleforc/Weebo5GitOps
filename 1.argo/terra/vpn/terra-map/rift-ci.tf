# Rift of Sym's release workflow (GitHub-hosted runner) joins the VPN for one step, to
# push the bundles into RustFS — and reaches nothing else: its group's only policy is TCP
# 9000 to the RustFS service, routed through the in-cluster exit node.
resource "netbird_group" "rift-ci" {
  name = "rift-ci"
}

resource "netbird_setup_key" "rift-ci" {
  name           = "rift-ci setup key"
  expiry_seconds = 0
  type           = "reusable"
  auto_groups    = [netbird_group.rift-ci.id]
  # A CI peer lives for one job; ephemeral peers are removed once they go offline.
  ephemeral   = true
  revoked     = false
  usage_limit = 0
}

resource "netbird_group" "rift-s3" {
  name = "rift-s3"
}

resource "netbird_network" "rift-s3" {
  name        = "rift-s3"
  description = "RustFS S3 API, for the Rift of Sym release workflow"
}

# The service name, not bucket.batleforc.fr: that host shares Traefik's IP and port with
# every other vpn-only service, so allowing it would allow all of them.
resource "netbird_network_resource" "rift-s3" {
  network_id = netbird_network.rift-s3.id
  name       = "rustfs-svc"
  address    = "rustfs-svc.s3.svc.cluster.local"
  groups     = [netbird_group.rift-s3.id]
  enabled    = true
}

resource "netbird_network_router" "rift-s3" {
  network_id  = netbird_network.rift-s3.id
  peer_groups = [netbird_group.exit-node-base.id]
  masquerade  = true
  enabled     = true
}

resource "netbird_policy" "rift-ci" {
  name    = "Rift CI to S3"
  enabled = true

  rule {
    action        = "accept"
    bidirectional = false
    enabled       = true
    protocol      = "tcp"
    ports         = ["9000"]
    name          = "rift-ci-s3"
    sources       = [netbird_group.rift-ci.id]
    destinations  = [netbird_group.rift-s3.id]
  }
}

# Copied by hand into the GitHub repository secret NETBIRD_SETUP_KEY of rift-of-sym.
resource "vault_kv_secret_v2" "rift-ci" {
  mount = "mv"
  name  = "risym/vpn"
  data_json = jsonencode(
    {
      NETBIRD_SETUP_KEY = netbird_setup_key.rift-ci.key
    }
  )
}
