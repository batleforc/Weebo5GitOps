resource "netbird_network" "lab" {
  name        = "Lab Network"
  description = "Network for the lab environment also named Weebo SI"
}

resource "netbird_group" "lab" {
  name = "lab"
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
  name  = "reserved/lab"
  data_json = jsonencode(
    {
      KUBERNETES_SETUP_KEY = netbird_setup_key.lab-master.key
    }
  )
}
