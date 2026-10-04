# Mise en place de Kanidm via l'opérateur kaniop

## Useful links

- [Kanidm Doc](https://kanidm.github.io/kanidm/stable/introduction_to_kanidm.html)
- [Kanidm GitHub](https://github.com/kanidm/kanidm)

## Introduction

Kanidm est un gestionnaire d'identités open-source conçu pour être simple à déployer et à gérer. L'opérateur kaniop facilite l'installation et la gestion de Kanidm via Kubernetes ceci incluant la création des ressources via une CRD (Custom Resource Definition).

## Pros

- Facilité d'installation et de gestion via Kubernetes
- GitOps friendly
- RUST !

## Cons

- Moins de fonctionnalités avancées par rapport à d'autres solutions d'identité
- Communauté plus petite que d'autres solutions d'identité
- Moins de documentation et de support disponible

## Pour info

Le lien permettant de changer le mot de passe d'un utilisateur est a retrouver dans les événement lier a l'utilisateur, attention pour avoir le lien correctement a bien le prendre dans events (via K9S) et pas directement dans l'object.

## Conclusion

Kanidm via l'opérateur kaniop est une option intéressante pour les organisations qui cherchent une solution d'identité simple à déployer et à gérer via Kubernetes. Cependant, il est important de considérer les besoins spécifiques de votre organisation et de comparer Kanidm avec d'autres solutions d'identité avant de prendre une décision finale.

Pour ma part je ne pense pas que Kanidm soit la meilleure option pour mon cas d'utilisation, mais je vais continuer à suivre son développement et à évaluer ses fonctionnalités à l'avenir. Il reste disponible de le helm chart Auth.
