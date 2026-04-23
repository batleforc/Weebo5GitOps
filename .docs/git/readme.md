# Server git ?

Avant toute choses, je n'ai pas choisis Gitlab étant donné que je le trouve trop lourd pour ce que je veux et vais faire. Par le passé j'ai utilisé Gitea, mais par envie de changement et de découverte j'ai décidé de migrer vers Forgejo, qui est un fork de Gitea, mais avec une vraie communauté.

## Rebranding ?!

Et oui, a travers Weebo5 je vais essayer de faire un maximum de rebranding possible, et cela affin d'inclure mon logo un peu partout. Oui je peux encore mettre mes chaussures :P.

[Customizing forgejo](https://forgejo.org/docs/next/contributor/customization/)

## CI

J'ai actuellement 2 CI en vision, l'historique qui est Tekton et la nouvelle qui est Forgejo Action. Je vais essayer de découvrir un maximum la seconde mais je garde Tekton sous le coude en cas de besoin, et surtout pour faire le parallèle entre les deux, et ainsi faire un comparatif.

Pour l'usage que je souhaite en faire, je pense uttilisé la solution en cours de développement basé sur les repos suivant:

- [Forgejo runner but with kube](https://github.com/eleboucher/runner)
- [Hardened Kubernetes runner](https://codeberg.org/ppaslan/forgejo-kubernetes-runners)

### Build docker

L'objectif est de faire mes premiers pas avec l'user-namespace dans kube et de commencer a faire du build via Buildah.
