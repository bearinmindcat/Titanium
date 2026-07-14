#!/usr/bin/env bash
# Apply ONE patch to a UGC-150 tree.
# Usage: tools/apply-single.sh patches/cromite/Foo.patch /path/to/ugc-src [--dry-run]
set -uo pipefail
P="${1:?usage: apply-single.sh <patch> <ugc-src> [--dry-run]}"
TREE="${2:?need target tree}"; DRY="${3:-}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
f="$REPO/$P"; [ -f "$f" ] || f="$P"; [ -f "$f" ] || { echo "no such patch: $P"; exit 1; }
if [ "$DRY" = "--dry-run" ]; then
  patch -p1 --forward --fuzz=3 --dry-run -d "$TREE" < "$f" >/dev/null 2>&1 \
    && echo "ok(dry): $P" || { echo "REJECT: $P"; exit 1; }
else
  patch -p1 --forward --fuzz=3 -d "$TREE" < "$f" && echo "applied: $P"
fi
