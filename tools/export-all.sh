#!/usr/bin/env bash
# Regenerate the hardening layer as a diff from a git baseline of the UGC-150 tree.
# Prereq: git init the fresh UGC-150 tree + `git tag ugc-pristine` BEFORE applying patches,
# then apply your changes, then run this to capture them.
# Usage: tools/export-all.sh /path/to/ugc-150/src/tree
set -uo pipefail
TREE="${1:?usage: tools/export-all.sh <ugc-150-git-tree>}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
[ -d "$TREE/.git" ] || { echo "tree is not a git repo (git init + tag ugc-pristine first)"; exit 1; }
cd "$TREE" || exit 1
git add -A
# full delta vs the pristine baseline, excluding build output + vendored toolchains + generated credits
git diff ugc-pristine -- . \
  ':(exclude)out/*' ':(exclude)third_party/llvm-build' \
  ':(exclude)components/resources/sample_credits.html' \
  > "$REPO/hardening-layer-150.patch"
echo "wrote $REPO/hardening-layer-150.patch ($(wc -l < "$REPO/hardening-layer-150.patch") lines)"
echo "NOTE: to split into per-vendor patches, commit each logical change separately then"
echo "      git format-patch."
