#!/usr/bin/env bash
# uninstall.sh — Désinstalle le plugin Claude Code « forge » et retire le catalogue « dotfiles »
#
# Seuls forge et le catalogue dotfiles sont retirés ; les autres plugins et catalogues
# ne sont pas touchés. Le dépôt lui-même n'est pas modifié.

set -e

MARKETPLACE="dotfiles"
PLUGIN="forge@dotfiles"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✔]${NC} $1"; }
error() { echo -e "${RED}[✘]${NC} $1"; exit 1; }

echo ""
echo "=== Désinstallation du plugin forge ==="
echo ""

command -v claude >/dev/null 2>&1 || error "Claude Code est introuvable."

if claude plugin list --json | grep -q "\"id\": \"$PLUGIN\""; then
  claude plugin uninstall "$PLUGIN" --scope user
  info "Plugin $PLUGIN désinstallé"
else
  info "Plugin $PLUGIN absent (aucune action)"
fi

if claude plugin marketplace list --json | grep -q "\"name\": \"$MARKETPLACE\""; then
  claude plugin marketplace remove "$MARKETPLACE"
  info "Catalogue $MARKETPLACE retiré"
else
  info "Catalogue $MARKETPLACE absent (aucune action)"
fi

echo ""
echo "=== Désinstallation terminée ==="
echo "Ouvre une nouvelle session Claude Code pour que le changement prenne effet."
