# Bibliothèque d'agent-engine

Ce dossier `claude/` est le plugin Claude Code **`forge`**. En plus des commandes et skills de Claude Code, il
contient la **bibliothèque** du moteur de boucle agentique **agent-engine** (`D:\Projet\IA\agent-engine`) : les
rôles, les cycles et les schémas de livrables. Ce document dit ce qu'elle contient, comment agent-engine la
trouve, ses formats, ses règles, et ce qu'il reste à faire.

La conception complète est dans agent-engine : `D:\Projet\IA\agent-engine\docs\ARCHITECTURE-AGENTIQUE.md`,
section 7 « La direction du projet ».

## Sommaire

1. [Ce qu'est cette bibliothèque](#1-ce-quest-cette-bibliothèque)
2. [Ce qu'elle contient](#2-ce-quelle-contient)
3. [Les formats](#3-les-formats)
   - 3.1 [Un rôle](#31-un-rôle)
   - 3.2 [Un cycle](#32-un-cycle)
   - 3.3 [Un schéma de livrable](#33-un-schéma-de-livrable)
4. [Les règles](#4-les-règles)
5. [État actuel](#5-état-actuel)
6. [À faire dans dotfiles](#6-à-faire-dans-dotfiles)
7. [À faire dans agent-engine](#7-à-faire-dans-agent-engine)

---

## 1. Ce qu'est cette bibliothèque

agent-engine est un **programme installé sur la machine** qui exécute des **cycles** d'agents : chaque nœud
d'un cycle est une boucle « travailler → vérifier → corriger », et c'est le programme, jamais le modèle, qui
décide qu'un nœud a réussi. Le moteur ne connaît **aucun rôle ni aucun cycle par son nom** : il les lit ici.

### Comment agent-engine la trouve

La bibliothèque est **distribuée dans le plugin `forge@dotfiles`**, installé par le gestionnaire de plugins de
Claude Code (`install.ps1` / `install.sh` à la racine du dépôt). agent-engine la lit dans le dossier où ce
plugin est installé, comme Claude Code y lit les commandes et les skills :

1. exécuter `claude plugin list --json` ;
2. prendre l'entrée dont `id` vaut `forge@dotfiles` ;
3. lire `roles/`, `cycles/` et `schemas/` sous son `installPath`.

Le moteur lit d'abord le `.claude/` du projet, puis la bibliothèque du plugin ; un fichier de même nom dans
le projet l'emporte.

Constaté le 2026-10-13 (Claude Code 2.1.284) :

```json
{
  "id": "forge@dotfiles",
  "version": "0.1.0",
  "scope": "user",
  "enabled": true,
  "installPath": "C:\\Users\\ghale\\.claude\\plugins\\cache\\dotfiles\\forge\\0.1.0"
}
```

- `installPath` est une **copie** du plugin faite par Claude Code à l'installation, à partir des fichiers
  présents sur le disque (commités ou non), pas un lien vers ce dépôt.
- La **version fait partie du chemin** : il ne faut jamais le mémoriser ni l'écrire en dur, mais le relire
  à chaque exécution.
- agent-engine ne lit ni ce dépôt (la source, qui peut contenir des modifications non publiées) ni le fichier
  interne `~/.claude/plugins/installed_plugins.json` (format non garanti) : il passe par la commande `claude`.

---

## 2. Ce qu'elle contient

```text
claude/                     le plugin « forge »
├── .claude-plugin/
│   └── plugin.json         identité et version du plugin
├── commands/, skills/      pour Claude Code (hors bibliothèque)
├── roles/                  QUI agit : les consignes d'un agent (nom libre)
│   ├── coder.md            implémente la tâche jusqu'à ce que les vérifications passent
│   ├── tester.md           écrit, avant le code, des tests qui doivent échouer
│   ├── architect.md        rend un plan structuré, sans rien modifier
│   ├── reviewer.md         rend un verdict structuré sur le changement, sans rien modifier
│   ├── redacteur.md        rédige un article Markdown        (exemple hors code)
│   └── relecteur.md        rend un verdict sur un article     (exemple hors code)
├── cycles/                 L'ENCHAÎNEMENT des nœuds
│   ├── developpement.yaml  architect → tester → coder → reviewer (refus → coder)
│   └── article.yaml        redacteur → relecteur (refus → redacteur)
├── schemas/                LA FORME des livrables structurés (JSON Schema écrit en YAML)
│   ├── plan.yaml           livrable de l'architect
│   └── verdict.yaml        livrable du reviewer et du relecteur
└── BIBLIOTHEQUE-AGENT-ENGINE.md   ce document
```

**Ce qui n'y est pas : les profils** (comment vérifier un projet : build, tests, lint…). Un profil dépend du
projet : il est écrit dans le projet par `agent init`, après un scan par un agent, et mis à jour par
`agent init --update`. Un cycle s'appuie sur le profil du projet où il tourne.

---

## 3. Les formats

### 3.1 Un rôle

Un fichier Markdown avec un en-tête YAML, lu par agent-engine (format déjà en service) :

```markdown
---
name: tester                 # obligatoire, identique au nom du fichier
description: une phrase      # obligatoire ; aucun autre champ n'est accepté
---

## Mission … ## Règles … ## Livrable (si structuré) … ## Fin de travail …
```

Le rôle ne contient que des **consignes**. Il ne fixe pas ce qui est vérifié : c'est le **cycle** qui dit quel
livrable un nœud doit produire, et c'est le **programme** qui le vérifie. Un rôle ne contient aucun savoir de
projet : les conventions d'un projet sont dans ses règles (`<projet>/.claude/rules/`), transmises à l'agent.

### 3.2 Un cycle

**Format proposé (v0)**, à fixer quand agent-engine saura exécuter les cycles :

| Champ | Rôle |
|---|---|
| `name`, `description` | Identité du cycle |
| `start` | Le premier nœud |
| `nodes.<nœud>.role` | Le rôle (un fichier de `roles/`) |
| `nodes.<nœud>.livrable` | Ce que le nœud doit produire, donc comment le programme le vérifie (tableau ci-dessous) |
| `nodes.<nœud>.schema` | Pour un livrable `document` : le schéma de `schemas/` |
| `nodes.<nœud>.outils` | `lecture` : Read, Glob, Grep seulement. Absent : les outils d'écriture aussi |
| `transitions.<nœud>` | Le nœud suivant selon le résultat vérifié (`valide`, `accepte`, `refuse`) ; `fin` termine le cycle |
| `limits` | `tours_par_noeud`, `allers_retours` : bornent le coût |

Les types de livrables, connus du programme :

| `livrable` | Ce que le programme vérifie | Exemple |
|---|---|---|
| `fichiers` | Les commandes du profil du projet passent, le projet est modifié, les tests existants sont intacts | coder, redacteur |
| `rouge` | Les **nouveaux** tests échouent, les tests existants passent | tester |
| `document` | La sortie structurée respecte son schéma, puis sa cohérence avec le dépôt | architect (`plan`) |
| `verdict` | La forme (schéma `verdict`), un refus a au moins une remarque, chaque remarque cite un fichier du diff | reviewer, relecteur |

### 3.3 Un schéma de livrable

Un fichier JSON Schema écrit en YAML. Il décrit la **forme** d'un livrable structuré ; le programme y ajoute
ses contrôles propres (cohérence avec le dépôt, remarques qui citent le diff).

---

## 4. Les règles

1. **Le programme décide, jamais le modèle.** Un nœud ne réussit que si son livrable est vérifié par le
   programme.
2. **Un avis peut renvoyer au travail, jamais conclure seul.** Un `verdict` qui refuse renvoie au nœud
   précédent ; un `verdict` qui accepte ne vaut que si les vérifications du projet passent aussi.
3. **Le contrat appartient au programme.** Un rôle précise des consignes ; il ne change pas ce qui est vérifié.
4. **Tout est borné.** Tours par nœud et allers-retours : un cycle qui n'aboutit pas s'arrête en échec.

---

## 5. État actuel

- La bibliothèque est versionnée et publiée dans le plugin `forge@dotfiles`, version `0.1.0`, installé et
  vérifié le 2026-10-13 : la copie installée contient `roles/`, `cycles/` et `schemas/`.
- agent-engine sait déjà lire un **rôle** (`agent run --role <nom>`), mais seulement dans le
  `<projet>/.claude/roles/` du projet : pour s'en servir aujourd'hui, copier le fichier dans le projet.
- agent-engine ne sait **pas encore** lire cette bibliothèque, ni exécuter un cycle, ni valider un `document`
  ou un `verdict`, ni vérifier un livrable `rouge`. La direction est décidée (2026-10-12), l'implémentation
  est à venir (section 7).

---

## 6. À faire dans dotfiles

1. Relire les rôles et les cycles, et les ajuster : ce sont des propositions.
2. À chaque modification de la bibliothèque, augmenter la `version` de `claude/.claude-plugin/plugin.json`,
   puis relancer `install.ps1` / `install.sh` : agent-engine verra la nouvelle version au lancement suivant.

---

## 7. À faire dans agent-engine

Pour mémoire ; c'est agent-engine qui porte ces travaux :

1. Trouver la bibliothèque par `claude plugin list --json` (section 1, « Comment agent-engine la trouve »),
   à chaque lancement ; lecture du projet, puis de la bibliothèque, le projet l'emportant. Cas d'erreur, avec
   un message clair (recommandations) :
   - `claude` introuvable dans le PATH ;
   - aucune entrée `forge@dotfiles` → « plugin non installé : lancer `install.ps1` du dépôt dotfiles » ;
   - entrée présente mais `"enabled": false` → traiter comme absent ;
   - `installPath` sans `roles/`, `cycles/` ou `schemas/` → bibliothèque incomplète.
2. Les vérificateurs de livrables : `document` (schéma + dépôt), `verdict`, `rouge`.
3. L'exécution des cycles décrits dans `cycles/` (LangGraph), avec leurs limites.
