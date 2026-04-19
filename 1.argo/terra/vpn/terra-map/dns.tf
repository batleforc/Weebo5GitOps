resource "netbird_nameserver_group" "dns-blocky" {
  name        = "Blocky DNS"
  description = "Blocky DNS"
  nameservers = [
    {
      ip      = "10.96.0.11"
      ns_type = "udp"
      port    = 53
    }
  ]
  groups                 = [data.netbird_group.weebo_admin.id]
  search_domains_enabled = false
  enabled                = true
  primary                = true
}
