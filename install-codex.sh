#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_root="$repo_root/codex-skills"
skills=(
  "project-orchestrate"
  "phase-execute"
  "task-implement"
  "project-status"
  "yolo"
)

usage() {
  cat <<'EOF'
Usage: install-codex.sh [--user | --repo [PROJECT_DIR] | --target SKILLS_DIR]

Options:
  --user                 Install to the current Codex user skills directory:
                         $HOME/.agents/skills. This is the default.
  --repo [PROJECT_DIR]   Install to PROJECT_DIR/.agents/skills, or to the
                         current working directory if PROJECT_DIR is omitted.
  --target SKILLS_DIR    Install directly into an explicit skills directory.
  -h, --help             Show this help.
EOF
}

target_root="${HOME}/.agents/skills"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)
      target_root="${HOME}/.agents/skills"
      shift
      ;;
    --repo)
      shift
      project_dir="${PWD}"
      if [[ $# -gt 0 && "$1" != -* ]]; then
        project_dir="$1"
        shift
      fi
      project_dir="$(cd "$project_dir" && pwd)"
      target_root="${project_dir}/.agents/skills"
      ;;
    --target)
      if [[ $# -lt 2 ]]; then
        echo "--target requires a skills directory" >&2
        exit 1
      fi
      target_root="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

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
