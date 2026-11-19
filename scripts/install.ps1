# Install the SDD kit into a target project (Windows PowerShell).
# Usage: scripts\install.ps1 -Target <dir> [-Force]
param(
  [Parameter(Mandatory = $true)][string]$Target,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'

$Kit = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path $Target -PathType Container)) { throw "Target directory not found: $Target" }
$Target = (Resolve-Path $Target).Path

function Copy-Dir([string]$Src, [string]$Dst) {
  if (-not (Test-Path $Src)) { return }
  Get-ChildItem -Path $Src -Recurse -File |
    Where-Object { $_.Name -ne '.gitkeep' -and $_.Name -ne 'settings.local.json' } |
    ForEach-Object {
      $rel = $_.FullName.Substring($Src.Length).TrimStart('\', '/')
      $dest = Join-Path $Dst $rel
      if ((Test-Path $dest) -and -not $Force) {
        Write-Host "skip (exists): $dest"
      } else {
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Copy-Item $_.FullName $dest -Force
        Write-Host "installed: $dest"
      }
    }
}

Copy-Dir "$Kit\.claude\agents"   "$Target\.claude\agents"
Copy-Dir "$Kit\.claude\commands" "$Target\.claude\commands"
Copy-Dir "$Kit\.claude\skills"   "$Target\.claude\skills"
Copy-Dir "$Kit\.claude\hooks"    "$Target\.claude\hooks"
Copy-Dir "$Kit\templates"        "$Target\.sdd\templates"
Copy-Dir "$Kit\evals\rubrics"    "$Target\.sdd\evals\rubrics"
foreach ($s in 'deterministic.sh', 'run-rubric.sh') {
  $dest = "$Target\.sdd\evals\$s"
  if ((Test-Path $dest) -and -not $Force) { Write-Host "skip (exists): $dest" }
  else {
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item "$Kit\evals\$s" $dest -Force
    Write-Host "installed: $dest"
  }
}

$kitSettings = "$Kit\.claude\settings.json"
if (Test-Path $kitSettings) {
  $dest = "$Target\.claude\settings.json"
  if ((Test-Path $dest) -and -not $Force) {
    Write-Host "NOTE: $dest exists; merge permissions/hooks from the kit manually."
  } else {
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item $kitSettings $dest -Force
    Write-Host "installed: $dest"
  }
}

New-Item -ItemType Directory -Force -Path "$Target\specs\adr" | Out-Null
if (-not (Test-Path "$Target\CLAUDE.md")) {
  Write-Host "NOTE: no CLAUDE.md found. Run /sdd-init in Claude Code to create it from the template."
}
Write-Host "`nDone. Open the project in Claude Code and run: /sdd-init <your idea>"
