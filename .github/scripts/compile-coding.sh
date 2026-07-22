#!/usr/bin/env bash
set -euo pipefail

# Compile every .cpp under coding/ (C++17 competitive-programming templates + solutions).
# Flags match coding/README.md: g++ -std=c++17 -O2 -Wall
# Meta puzzle solutions expose only a judge entrypoint (no main) — those are compiled with -c.

CXX="${CXX:-g++}"
CXXFLAGS=(-std=c++17 -O2 -Wall -Wextra)
ROOT="$(pwd)"

if [[ ! -d coding ]]; then
  echo "coding/ not found (run from repo root)" >&2
  exit 1
fi

mapfile -t files < <(find coding -type f -name '*.cpp' | sort)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .cpp files under coding/" >&2
  exit 1
fi

outdir="$(mktemp -d)"
trap 'rm -rf "$outdir"' EXIT

failed=0
ok=0
echo "Compiling ${#files[@]} files with ${CXX} ${CXXFLAGS[*]}..."

has_main() {
  grep -qE '(^|[^[:alnum:]_])main[[:space:]]*\(' "$1"
}

for f in "${files[@]}"; do
  out="$outdir/${f%.cpp}"
  mkdir -p "$(dirname "$out")"
  echo "  $f"
  if has_main "$ROOT/$f"; then
    if ! "$CXX" "${CXXFLAGS[@]}" -o "$out" "$ROOT/$f"; then
      echo "FAIL: $f" >&2
      failed=1
      continue
    fi
  else
    if ! "$CXX" "${CXXFLAGS[@]}" -c -o "$out.o" "$ROOT/$f"; then
      echo "FAIL: $f" >&2
      failed=1
      continue
    fi
  fi
  ok=$((ok + 1))
done

if [[ "$failed" -ne 0 ]]; then
  echo "Compiled $ok/${#files[@]}; one or more files failed" >&2
  exit 1
fi

echo "OK: compiled $ok/${#files[@]} files"
