#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob
files=(resume/*.tex)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No resume .tex files found under resume/" >&2
  exit 1
fi

for f in "${files[@]}"; do
  dir="$(dirname "$f")"
  base="$(basename "$f")"
  echo "Compiling $f..."
  (
    cd "$dir"
    latexmk -pdf -interaction=nonstopmode -halt-on-error "$base"
    latexmk -c "$base"
  )
done
