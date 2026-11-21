# claude-forge — la feuille de route

Ce qui reste à faire dans le plugin `forge`. Un point qui touche un autre projet renvoie à sa feuille de route.

| Point | Contenu | État |
|---|---|---|
| Centraliser les formats communs | Le plugin centralise les commandes et les formats communs à toutes les briques et à tous les projets : rien n'est recopié dans les projets. Restent dans agent-engine : la forme du message de commit (décrite dans `roles/livreur.md`, vérifiée par `domain/delivery.py`) et le titre et le message de la pull request (en dur dans `adapters/github_host.py`). À faire : ces formats dans forge, lus par agent-engine, qui continue de vérifier le résultat | Décidé le 2026-10-29, à concevoir |
| Projets d'infrastructure déclarative | Faire produire par agent-engine des projets comme `vps-k3s` et `k3s-services` (Ansible, manifests, une commande, aucun secret, contrôles en lecture seule, rejeu sans changement). Phase 1 : rôles `concepteur-infra`, `auteur-infra`, `relecteur-infra` et cycle `infrastructure` (ici), modèle de profil `ansible` (agent-engine), passage sur machine vierge (VM Incus jetable, `vps-k3s`). Phase 2 : pilote, faire produire par le cycle un vrai morceau (le service `redis/` de `k3s-services`) et le comparer au standard fait à la main. Phase 3 : skill `/forge:infra-setup`, qui pose le squelette d'un nouveau projet de ce type (d'après le pilote). Phase 4 : un projet complet par specbook → planforge → `agent epic --cycle infrastructure`. La release qui publie le cycle (`feat` → 0.11) doit sortir avec agent-engine réglé sur cette série (voir sa feuille de route) | Décidé le 2026-11-21 ; **phase 1 écrite** (2026-11-21), non publiée |
| Audit des briques | Audit du 2026-10-29 : agent-engine et Foundation n'ont aucune commande Claude Code. Vérifié le 2026-10-30 : planforge, specbook et jira-sync non plus (pas de `.claude/`). Reste à chercher les formats communs écrits en dur dans leur code (commit, pull request…) | À faire |

## Liens avec les autres feuilles de route

- **agent-engine** : « Centraliser dans forge », côté lecture, dans la
  [feuille de route d'agent-engine](../../Foundation/briques/agent-engine/docs/feuille-de-route.md).
- **agent-engine** : « Projets d'infrastructure déclarative » (modèle de profil `ansible`, série de forge exigée),
  dans la même feuille de route.
- **Foundation** : forge cité comme prérequis de la chaîne, et la décision D6 (source de vérité des formats), dans la
  [feuille de route de Foundation](../../Foundation/docs/feuille-de-route.md).
