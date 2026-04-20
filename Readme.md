# Weebo 5 Production upgrade

This is the base project for the Weebo 5 production upgrade.

## Exist in V4 and need to be upgraded in V5

- [x] SSO Provider
  - OLD: [Zitadel](https://zitadel.com/)
  - NEW: [Zitadel](https://zitadel.com/) or [Authentik](https://goauthentik.io/) or [Kanidm](https://github.com/pando85/kaniop)
- [x] Secret Storage
  - OLD: [Vault](https://www.vaultproject.io/) x [BankVault](https://www.bank-vaults.io/)
  - NEW: [OpenBao](https://openbao.io/) or [Vault](https://www.vaultproject.io/) x [BankVault](https://www.bank-vaults.io/) x [Kubernetes External Secrets](https://external-secrets.io/)
    - Add support for [numberly/vault-db-injector](https://github.com/numberly/vault-db-injector) and migrate existing connection to it
- [ ] Monitoring X Logging
  - OLD: [PromStack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) x [Loki](https://grafana.com/oss/loki/)
  - NEW: [Coroot](https://coroot.com/) X [Grafana](https://grafana.com/)
- [ ] Git Stack
  - OLD: [Gitea](https://gitea.io/) x [Tekton](https://tekton.dev/)
  - NEW: [Gitea](https://gitea.io/) or [Forgejo](https://forgejo.org/) ? X [Tekton](https://tekton.dev/) or [ArgoEvents](https://argoproj.github.io/argo-events/) ?
- [x] GitOps - [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [ ] Registry - [Harbor](https://goharbor.io/)
- [x] VPN
  - OLD : [WireGuard](https://www.wireguard.com/)
  - NEW : [NetBird](https://netbird.io/)
    - Output Node setup with Strict Routing and DNS filtering through Blocky (Thanks [SoulKyu/cpg](https://github.com/SoulKyu/cpg) that made the debugging of this super easy)
- [x] DNS
  - OLD: [Bind9](https://www.isc.org/bind/)
  - NEW:
    - [x] Public : [Bind9](https://www.isc.org/bind/) x [ExternalDNS](https://github.com/kubernetes-sigs/external-dns)
    - [x] Private :
      - [ ] [AdGuard](https://adguard.com/en/welcome.html)
      - [x] [Blocky](https://0xerr0r.github.io/blocky/latest/configuration/)
- [x] Ingress
  - OLD: [HaProxy](https://www.haproxy.com/)
  - NEW: [Traefik](https://traefik.io/)
- [x] CNI - [Cilium](https://cilium.io/)
  - [ ] !TODO: Message a moi meme pour demain, passer en netpol strict avec zero ouverture by default, et n'ouvrir que ce qui est nécessaire
- [ ] [Eclipse Che](https://www.eclipse.org/che/)
- [ ] Tofu Hooks
- [ ] [CertManager](https://cert-manager.io/) x DNS01-rfc2136
- [x] [Rybbit](https://github.com/rybbit-io/rybbit) - For tracking
- [ ] [Stalward MAIL](https://stalw.art/) <https://stalw.art/docs/cluster/orchestration/kubernetes/> <https://github.com/bilbilak/terraform-provider-stalwart-mail>
- [ ] Basic Monitoring
  - OLD: [Uptime Kuma](https://kuma.io/)
  - New: [Gatus](https://github.com/TwiN/gatus)
- [ ] Matrix
  - OLD: [Element](https://element.io/)
  - NEW: [Tuwunel](https://github.com/matrix-construct/tuwunel) when [OIDC support will be ready](https://github.com/matrix-construct/tuwunel/issues/246)
- [ ] Notification
  - OLD: [Gotify](https://gotify.net/)
  - NEW: Not decided yet

## Folder WF

- .* - Global folder
- 0.* - Install folder
- 1.* - Infra folder
  - 1.argo - ArgoCD folder, dedicated to infra related ressources deployed directly by ArgoCD
  - 1.helm - Helm folder, dedicated to special Helm charts rewriting public one that i don't like/too limited for my use case/too long to be merged in the original one
- 2.* - Apps folder - dedicated for app comming from outside of the scope (like external secret setup, personal project, etc ...)
- 3.* - Post-install folder
