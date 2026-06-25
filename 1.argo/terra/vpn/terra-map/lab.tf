resource "netbird_network" "lab" {
  name        = "Lab Network"
  description = "Network for the lab environment also named Weebo SI"
}

variable "assign_group" {
  type    = set(string)
  default = [data.netbird_group.weebo_admin.id]
}

resource "netbird_group" "lab" {
  name = "lab"
}

resource "netbird_network_router" "lab" {
  network_id  = netbird_network.lab.id
  peer_groups = [netbird_group.lab.id]
  enabled     = true
}

resource "netbird_setup_key" "lab-master" {
  name                   = "lab-master setup key"
  expiry_seconds         = 0 # 30 days
  type                   = "reusable"
  allow_extra_dns_labels = true
  auto_groups            = [netbird_group.lab.id]
  ephemeral              = false
  revoked                = false
  usage_limit            = 0
}

resource "vault_kv_secret_v2" "lab" {
  mount = "mv"
  name  = "reserved-lab/vpn-exit-node"
  data_json = jsonencode(
    {
      KUBERNETES_SETUP_KEY = netbird_setup_key.lab-master.key
    }
  )
}

resource "netbird_network_resource" "lab-pod-cidr-v4" {
  network_id  = netbird_network.lab.id
  name        = "Lab POD IPV4 CIDR"
  description = "Lab IPV4 CIDR"
  address     = "10.244.0.0/16"
  groups      = var.assign_group
  enabled     = true
}

resource "netbird_network_resource" "lab-pod-cidr-v6" {
  network_id  = netbird_network.lab.id
  name        = "Lab POD IPV6 CIDR"
  description = "Lab IPV6 CIDR"
  address     = "fd00:10:244::/56"
  groups      = var.assign_group
  enabled     = true
}

resource "netbird_network_resource" "lab-service-cidr-v4" {
  network_id  = netbird_network.lab.id
  name        = "Lab Service IPV4 CIDR"
  description = "Lab Service IPV4 CIDR"
  address     = "10.96.0.0/12"
  groups      = var.assign_group
  enabled     = true
}

resource "netbird_network_resource" "lab-service-cidr-v6" {
  network_id  = netbird_network.lab.id
  name        = "Lab Service IPV6 CIDR"
  description = "Lab Service IPV6 CIDR"
  address     = "fd00:10:96::/112"
  groups      = var.assign_group
  enabled     = true
}

resource "netbird_network_resource" "lab-wildcard-weebo-poc" {
  network_id  = netbird_network.lab.id
  name        = "Lab Wildcard weebo poc"
  description = "Lab *.weebo.poc"
  address     = "*.weebo.poc"
  groups      = var.assign_group
  enabled     = true
}

resource "netbird_network_resource" "lab-weebo-poc" {
  network_id  = netbird_network.lab.id
  name        = "Lab weebo poc"
  description = "Lab weebo.poc"
  address     = "weebo.poc"
  groups      = var.assign_group
  enabled     = true
}
