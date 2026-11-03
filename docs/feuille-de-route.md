# claude-forge — la feuille de route

Ce qui reste à faire dans le plugin `forge`. Un point qui touche un autre projet renvoie à sa feuille de route.

| Point | Contenu | État |
|---|---|---|
| Centraliser les formats communs | Le plugin centralise les commandes et les formats communs à toutes les briques et à tous les projets : rien n'est recopié dans les projets. Restent dans agent-engine : la forme du message de commit (décrite dans `roles/livreur.md`, vérifiée par `domain/delivery.py`) et le titre et le message de la pull request (en dur dans `adapters/github_host.py`). À faire : ces formats dans forge, lus par agent-engine, qui continue de vérifier le résultat | Décidé le 2026-10-29, à concevoir |
| Audit des briques | Audit du 2026-10-29 : agent-engine et Foundation n'ont aucune commande Claude Code. Vérifié le 2026-10-30 : planforge, specbook et jira-sync non plus (pas de `.claude/`). Reste à chercher les formats communs écrits en dur dans leur code (commit, pull request…) | À faire |

## Liens avec les autres feuilles de route

- **agent-engine** : « Centraliser dans forge », côté lecture, dans la
  [feuille de route d'agent-engine](../../IA/Foundation/briques/agent-engine/docs/feuille-de-route.md).
- **Foundation** : forge cité comme prérequis de la chaîne, et la décision D6 (source de vérité des formats), dans la
  [feuille de route de Foundation](../../IA/Foundation/docs/feuille-de-route.md).
