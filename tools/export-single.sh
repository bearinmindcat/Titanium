#!/usr/bin/env bash
# Regenerate ONE patch from a git-tracked UGC-150 tree (re-diff the files it touches vs ugc-pristine).
# Usage: tools/export-single.sh <git-tree> patches/cromite/Foo.patch <file1> [file2 ...]
set -uo pipefail
TREE="${1:?usage: export-single.sh <git-tree> <out-patch> <files...>}"
OUT="${2:?need out-patch path}"; shift 2
REPO="$(cd "$(dirname "$0")/.." && pwd)"
[ -d "$TREE/.git" ] || { echo "tree not a git repo (git tag ugc-pristine first)"; exit 1; }
( cd "$TREE" && git add -A && git diff ugc-pristine -- "$@" ) > "$REPO/$OUT"
echo "wrote $OUT ($(wc -l < "$REPO/$OUT") lines) from: $*"
