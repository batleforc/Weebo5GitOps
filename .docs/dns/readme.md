# DNS

Plusieurs provider DNS sont utilisés dans Weebo 5, chacun avec un rôle spécifique :

- in-dns
  - Gére les dns externe, C'est a dire toute les zone `batleforc.fr`, `weebo.fr`, `maxleriche.net`
  - Gére les dns interne, C'est a dire toute les zone `batleforc.poc`, `weebo.poc`,`maxleriche.poc`
- Blocky
  - Gére les dns de blocage, il va bloquer les domaines malveillants, les publicités, etc ...
  - Il est utilisé en forwarder pour Netbird, afin de bloquer les domaines malveillants pour les clients VPN
  - Il expose aussi les `cluster.local` pour les clients VPN, afin de leur permettre d'accéder aux services internes via le VPN
- Netbird
  - Gére les dns pour les clients VPN, il va forwarder les requêtes vers Blocky, qui va ensuite forwarder vers in-dns si le domaine n'est pas bloqué
  - Il expose certaine ressource dédié au client VPN
