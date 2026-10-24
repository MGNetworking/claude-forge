# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Dépôt personnel publiant le plugin Claude Code `forge` (commandes, skills et bibliothèque agent-engine),
distribué par le catalogue `claude-forge` que constitue ce dépôt. Voir `README.md`.

## Repository Structure

- `.claude-plugin/marketplace.json` — le catalogue `claude-forge`
- `claude/` — le plugin `forge` : `commands/`, `skills/`, et `roles/`, `cycles/`, `schemas/` lus par
  agent-engine (voir `claude/BIBLIOTHEQUE-AGENT-ENGINE.md`)
- `install.*` / `uninstall.*` — installent ou retirent le plugin via `claude plugin`

## Règles

- Toute commande s'appelle `/forge:<nom>` : une référence à une autre commande du plugin porte ce préfixe.
- Un skill est un dossier `claude/skills/<nom>/SKILL.md` ; ses fichiers annexes sont à côté, en chemins relatifs.
- Une commande ne doit pas être rangée dans un sous-dossier de `commands/` : le plugin ne la chargerait pas.
- Ne jamais modifier à la main la `version` de `claude/.claude-plugin/plugin.json` : Release Please la fixe
  à chaque release, d'après les messages de commit (Conventional Commits : `feat` → mineure, `fix` → correctif).
