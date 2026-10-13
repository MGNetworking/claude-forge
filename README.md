# dotfiles — Plugin Claude Code « forge »

Outils personnels pour Claude Code, publiés sous la forme d'un **plugin** : `forge`, distribué par le
catalogue `dotfiles` que constitue ce dépôt.

L'installation passe par le gestionnaire de plugins de Claude Code : elle ne crée aucun lien et ne touche ni
à `~/.claude/commands`, ni à `~/.claude/skills`, ni aux autres plugins. Elle s'annule entièrement.

---

## Structure

```
dotfiles/
├── .claude-plugin/
│   └── marketplace.json      ← le catalogue « dotfiles » : déclare le plugin forge
├── claude/                   ← le plugin « forge »
│   ├── .claude-plugin/
│   │   └── plugin.json       ← identité et version du plugin
│   ├── commands/             ← commandes Claude Code
│   ├── skills/               ← skills Claude Code (un dossier par skill, avec son SKILL.md)
│   ├── roles/                ← bibliothèque agent-engine : les rôles
│   ├── cycles/               ← bibliothèque agent-engine : les cycles
│   ├── schemas/              ← bibliothèque agent-engine : les schémas de livrables
│   └── BIBLIOTHEQUE-AGENT-ENGINE.md
├── install.ps1 / install.sh      ← installe ou met à jour le plugin
└── uninstall.ps1 / uninstall.sh  ← le retire
```

`roles/`, `cycles/` et `schemas/` ne servent pas à Claude Code : ils sont lus par **agent-engine**, dans le
dossier du plugin installé. Voir [claude/BIBLIOTHEQUE-AGENT-ENGINE.md](claude/BIBLIOTHEQUE-AGENT-ENGINE.md).

---

## Commandes et skills

Toutes s'appellent avec le préfixe du plugin : `/forge:<nom>`.

### Initialisation Git

| Commande | Description |
|---|---|
| `/forge:git-setup` | Orchestrateur — questionnaire guidé pour initialiser un projet complet |
| `/forge:git-setup-branches` | Créer les branches recommandées (GitHub Flow, GitFlow, Trunk-based) |
| `/forge:git-setup-gitignore` | Générer un `.gitignore` adapté au langage, framework et OS |
| `/forge:git-setup-gitattributes` | Générer un `.gitattributes` (fins de ligne, fichiers binaires) |
| `/forge:git-setup-release-please` | Configurer Release Please pour automatiser versions et CHANGELOG |
| `/forge:git-setup-actions` | Générer les workflows GitHub Actions (CI et/ou Release) |
| `/forge:git-setup-github` | Créer le dépôt GitHub avec description, topics, remote et protection des branches |

### Qualité

| Commande | Description |
|---|---|
| `/forge:arch-check` | Vérification de l'architecture — SOLID, règles de couche et conventions |
| `/forge:audit-prompts` | Auditer les fichiers `prompt-generateur-*.md` — complétude et cohérence |

### Apprentissage .NET

| Skill | Description |
|---|---|
| `/forge:fiches-dotnet` | Menu des fiches de révision .NET |
| `/forge:fiches-dotnet <module>` | Ouvre un module : `api`, `architecture`, `efcore`, `efcore-setup`, `patterns`, `security`, `testing`, `advanced`, `performance`, `multitenancy`, `niveau` |

---

## Installation

**Prérequis :** [Claude Code](https://claude.com/claude-code) installé, commande `claude` disponible.

Windows (PowerShell) :

```powershell
.\install.ps1
```

Linux / macOS / Git Bash :

```bash
./install.sh
```

Le script ajoute le catalogue `dotfiles` puis installe `forge@dotfiles`. Il revient à :

```bash
claude plugin marketplace add <chemin du dépôt>
claude plugin install forge@dotfiles --scope user
```

Ouvrir ensuite une **nouvelle session** Claude Code.

### Mettre à jour

Augmenter la `version` de `claude/.claude-plugin/plugin.json`, puis relancer le script d'installation : il
met à jour le catalogue et le plugin.

### Désinstaller

```powershell
.\uninstall.ps1
```

```bash
./uninstall.sh
```

Seuls le plugin `forge` et le catalogue `dotfiles` sont retirés.
