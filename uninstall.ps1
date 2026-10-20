# uninstall.ps1 - Desinstalle le plugin Claude Code "forge" et retire le catalogue "claude-forge"
#
# Seuls forge et le catalogue claude-forge sont retires ; les autres plugins et catalogues
# ne sont pas touches. Le depot lui-meme n'est pas modifie.

$ErrorActionPreference = "Stop"

$MARKETPLACE = "claude-forge"
$PLUGIN      = "forge@claude-forge"

function Write-Info { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "[X]  $msg" -ForegroundColor Red; exit 1 }

function Invoke-Claude {
    & claude @args
    if ($LASTEXITCODE -ne 0) { Write-Fail "Echec de : claude $($args -join ' ')" }
}

Write-Host ""
Write-Host "=== Desinstallation du plugin forge ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Fail "Claude Code est introuvable."
}

$plugins = (& claude plugin list --json) | ConvertFrom-Json
if ($plugins | Where-Object { $_.id -eq $PLUGIN }) {
    Invoke-Claude plugin uninstall $PLUGIN --scope user
    Write-Info "Plugin $PLUGIN desinstalle"
} else {
    Write-Info "Plugin $PLUGIN absent (aucune action)"
}

$marketplaces = (& claude plugin marketplace list --json) | ConvertFrom-Json
if ($marketplaces | Where-Object { $_.name -eq $MARKETPLACE }) {
    Invoke-Claude plugin marketplace remove $MARKETPLACE
    Write-Info "Catalogue $MARKETPLACE retire"
} else {
    Write-Info "Catalogue $MARKETPLACE absent (aucune action)"
}

Write-Host ""
Write-Host "=== Desinstallation terminee ===" -ForegroundColor Cyan
Write-Host "Ouvre une nouvelle session Claude Code pour que le changement prenne effet."
