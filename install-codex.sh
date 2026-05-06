#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_root="$repo_root/codex-skills"
target_root="${HOME}/.codex/skills"
skills=(
  "project-orchestrate"
  "phase-execute"
  "task-implement"
  "project-status"
  "yolo"
)

if [[ ! -d "$source_root" ]]; then
  echo "Missing source directory: $source_root" >&2
  exit 1
fi

mkdir -p "$target_root"

for skill in "${skills[@]}"; do
  source_dir="$source_root/$skill"
  target_dir="$target_root/$skill"

  if [[ ! -d "$source_dir" ]]; then
    echo "Missing skill directory: $source_dir" >&2
    exit 1
  fi

  rm -rf "$target_dir"
  cp -R "$source_dir" "$target_dir"
  echo "Installed $skill -> $target_dir"
done

echo "Codex skills installed to $target_root"
