$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRoot = Join-Path $repoRoot "codex-skills"
$targetRoot = Join-Path $HOME ".codex\skills"
$skills = @(
    "project-orchestrate",
    "phase-execute",
    "task-implement",
    "yolo"
)

if (-not (Test-Path $sourceRoot)) {
    throw "Missing source directory: $sourceRoot"
}

New-Item -ItemType Directory -Force $targetRoot | Out-Null

foreach ($skill in $skills) {
    $source = Join-Path $sourceRoot $skill
    $target = Join-Path $targetRoot $skill

    if (-not (Test-Path $source)) {
        throw "Missing skill directory: $source"
    }

    if (Test-Path $target) {
        Remove-Item -Recurse -Force $target
    }

    Copy-Item -Recurse -Force $source $target
    Write-Host "Installed $skill -> $target"
}

Write-Host "Codex skills installed to $targetRoot"
