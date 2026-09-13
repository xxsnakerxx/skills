#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

shopt -s nullglob
for skill_dir in "$root"/skills/*/; do
  name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    echo "✗ $name: missing SKILL.md"
    fail=1
    continue
  fi

  if [[ "$(head -n1 "$skill_file")" != "---" ]]; then
    echo "✗ $name: file must start with '---' frontmatter"
    fail=1
    continue
  fi

  fm=$(awk 'NR>1 && /^---$/ {exit} NR>1 {print}' "$skill_file")

  for key in name description license; do
    if ! grep -qE "^$key:[[:space:]]+" <<<"$fm"; then
      echo "✗ $name: missing frontmatter key '$key'"
      fail=1
    fi
  done

  fm_name=$(grep -E '^name:[[:space:]]+' <<<"$fm" | head -n1 | sed -E 's/^name:[[:space:]]+//; s/[[:space:]]+$//')
  if [[ "$fm_name" != "$name" ]]; then
    echo "✗ $name: frontmatter name '$fm_name' != directory '$name'"
    fail=1
  fi

  if ! [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "✗ $name: name must be kebab-case"
    fail=1
  fi
done

if [[ $fail -ne 0 ]]; then
  echo "validation failed"
  exit 1
fi
echo "✓ all skills valid"
