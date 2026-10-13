# install.ps1 - Installe le plugin Claude Code "forge" depuis le catalogue "dotfiles"
#
# Ne cree aucun lien et ne modifie ni ~/.claude/commands ni ~/.claude/skills :
# l'installation passe par le gestionnaire de plugins de Claude Code.
# Les autres plugins et catalogues ne sont pas touches.
# Relancer le script met a jour le catalogue et le plugin.

$ErrorActionPreference = "Stop"

$DOTFILES_DIR = $PSScriptRoot
$CLAUDE_DIR   = "$env:USERPROFILE\.claude"
$MARKETPLACE  = "dotfiles"
$PLUGIN       = "forge@dotfiles"

function Write-Info     { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warning2 { param($msg) Write-Host "[!]  $msg" -ForegroundColor Yellow }
function Write-Fail     { param($msg) Write-Host "[X]  $msg" -ForegroundColor Red; exit 1 }

function Invoke-Claude {
    & claude @args
    if ($LASTEXITCODE -ne 0) { Write-Fail "Echec de : claude $($args -join ' ')" }
}

Write-Host ""
Write-Host "=== Installation du plugin forge ===" -ForegroundColor Cyan
Write-Host "Catalogue : $DOTFILES_DIR"
Write-Host ""

# 1. Claude Code doit etre installe
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Fail "Claude Code est introuvable. Installe-le : https://claude.com/claude-code"
}
Write-Info "Claude Code $((& claude --version) -join ' ')"

# 2. Une ancienne installation par liens symboliques bloquerait le retour a l'etat de base
foreach ($name in "commands", "skills") {
    $path = Join-Path $CLAUDE_DIR $name
    if (Test-Path $path) {
        $item = Get-Item $path -Force
        if ($item.LinkType -and "$($item.Target)" -like "$DOTFILES_DIR*") {
            Write-Warning2 "$path est un lien vers ce depot (ancienne installation)."
            Write-Host     "     Supprime le lien seul, sans toucher au depot, puis relance ce script :"
            Write-Host     "     cmd /c rmdir `"$path`""
            exit 1
        }
    }
}

# 3. Le catalogue
$marketplaces = (& claude plugin marketplace list --json) | ConvertFrom-Json
if ($marketplaces | Where-Object { $_.name -eq $MARKETPLACE }) {
    Invoke-Claude plugin marketplace update $MARKETPLACE
    Write-Info "Catalogue $MARKETPLACE mis a jour"
} else {
    Invoke-Claude plugin marketplace add $DOTFILES_DIR
    Write-Info "Catalogue $MARKETPLACE ajoute"
}

# 4. Le plugin
$plugins = (& claude plugin list --json) | ConvertFrom-Json
if ($plugins | Where-Object { $_.id -eq $PLUGIN }) {
    Invoke-Claude plugin update $PLUGIN
    Write-Info "Plugin $PLUGIN mis a jour"
} else {
    Invoke-Claude plugin install $PLUGIN --scope user
    Write-Info "Plugin $PLUGIN installe"
}

$installed = ((& claude plugin list --json) | ConvertFrom-Json) | Where-Object { $_.id -eq $PLUGIN }
Write-Host ""
Write-Host "=== Installation terminee ===" -ForegroundColor Cyan
Write-Host "Version : $($installed.version)"
Write-Host "Dossier : $($installed.installPath)"
Write-Host ""
Write-Host "Ouvre une nouvelle session Claude Code ; les commandes s'appellent /forge:<nom>."
Write-Host "Liste des commandes : README.md"
