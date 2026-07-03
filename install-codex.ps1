param(
    [switch]$user,

    [string]$repo,

    [string]$target
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRoot = Join-Path $repoRoot "codex-skills"
$skills = @(
    "agentflow/skills/project-specify",
    "agentflow/skills/project-orchestrate",
    "agentflow/skills/phase-execute",
    "agentflow/skills/task-implement",
    "agentflow/skills/project-status",
    "utils/skills/yolo"
)

if (-not (Test-Path $sourceRoot)) {
    throw "Missing source directory: $sourceRoot"
}

$modeCount = 0
if ($user) { $modeCount++ }
if ($repo) { $modeCount++ }
if ($target) { $modeCount++ }

if ($modeCount -gt 1) {
    throw "Use only one install target: -user, -repo, or -target"
}

if ($target) {
    $resolvedTargetRoot = $target
} elseif ($repo) {
    $resolvedProjectPath = (Resolve-Path -LiteralPath $repo).Path
    $resolvedTargetRoot = Join-Path $resolvedProjectPath ".agents\skills"
} else {
    $resolvedTargetRoot = Join-Path $HOME ".agents\skills"
}

New-Item -ItemType Directory -Force $resolvedTargetRoot | Out-Null

foreach ($skill in $skills) {
    $skillName = Split-Path -Leaf $skill
    $source = Join-Path $sourceRoot $skill
    $target = Join-Path $resolvedTargetRoot $skillName

    if (-not (Test-Path $source)) {
        throw "Missing skill directory: $source"
    }

    if (Test-Path $target) {
        Remove-Item -Recurse -Force $target
    }

    Copy-Item -Recurse -Force $source $target
    Write-Host "Installed $skillName -> $target"
}

Write-Host "Codex skills installed to $resolvedTargetRoot"
