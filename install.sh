#!/usr/bin/env bash
# install.sh — Installe le plugin Claude Code « forge » depuis le catalogue « claude-forge »
#
# Ne crée aucun lien et ne modifie ni ~/.claude/commands ni ~/.claude/skills :
# l'installation passe par le gestionnaire de plugins de Claude Code.
# Les autres plugins et catalogues ne sont pas touchés.
# Relancer le script met à jour le catalogue et le plugin.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
MARKETPLACE="claude-forge"
PLUGIN="forge@claude-forge"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[✔]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }

echo ""
echo "=== Installation du plugin forge ==="
echo "Catalogue : $DOTFILES_DIR"
echo ""

# 1. Claude Code doit être installé
command -v claude >/dev/null 2>&1 || error "Claude Code est introuvable. Installe-le : https://claude.com/claude-code"
info "Claude Code $(claude --version)"

# 2. Une ancienne installation par liens symboliques bloquerait le retour à l'état de base
for name in commands skills; do
  path="$CLAUDE_DIR/$name"
  if [ -L "$path" ] && [[ "$(readlink "$path")" == "$DOTFILES_DIR"* ]]; then
    warning "$path est un lien vers ce dépôt (ancienne installation)."
    echo "     Supprime le lien seul, sans toucher au dépôt, puis relance ce script :"
    echo "     rm \"$path\""
    exit 1
  fi
done

# 3. L'ancien nom du catalogue (« dotfiles », avant le 2026-10-20) installerait forge en double
if claude plugin marketplace list --json | grep -q '"name": "dotfiles"'; then
  warning "Le catalogue porte encore son ancien nom, dotfiles (ancienne installation)."
  echo "     Retire-le, puis relance ce script :"
  echo "     claude plugin uninstall forge@dotfiles --scope user"
  echo "     claude plugin marketplace remove dotfiles"
  exit 1
fi

# 4. Le catalogue
if claude plugin marketplace list --json | grep -q "\"name\": \"$MARKETPLACE\""; then
  claude plugin marketplace update "$MARKETPLACE"
  info "Catalogue $MARKETPLACE mis à jour"
else
  claude plugin marketplace add "$DOTFILES_DIR"
  info "Catalogue $MARKETPLACE ajouté"
fi

# 5. Le plugin
if claude plugin list --json | grep -q "\"id\": \"$PLUGIN\""; then
  claude plugin update "$PLUGIN"
  info "Plugin $PLUGIN mis à jour"
else
  claude plugin install "$PLUGIN" --scope user
  info "Plugin $PLUGIN installé"
fi

echo ""
echo "=== Installation terminée ==="
echo ""
echo "Ouvre une nouvelle session Claude Code ; les commandes s'appellent /forge:<nom>."
echo "Liste des commandes : README.md"
