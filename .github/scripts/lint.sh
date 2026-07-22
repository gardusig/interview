#!/usr/bin/env bash
set -euo pipefail

mapfile -t files < <(
  find . -type f -name '*.md' \
    ! -path './.git/*' \
    ! -path './node_modules/*' \
    | sort
)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No markdown files found" >&2
  exit 1
fi

echo "Linting ${#files[@]} markdown files..."
markdownlint "${files[@]}"
lychee "${files[@]}" --exclude 'https://linkedin.com'
