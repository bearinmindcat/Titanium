#!/usr/bin/env bash
# Apply the full patches/series (UGC base + Titanium layer) to a pristine Chromium-150 tree.
# Usage: tools/apply-all.sh /path/to/ugc-150/src   [--dry-run]
set -uo pipefail
TREE="${1:?usage: tools/apply-all.sh <ugc-150-src-tree> [--dry-run]}"
DRY="${2:-}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SERIES="$REPO/patches/series"
[ -d "$TREE" ] || { echo "no such tree: $TREE"; exit 1; }
[ -f "$SERIES" ] || { echo "no series file: $SERIES"; exit 1; }
ok=0; rej=0; skip=0
while IFS= read -r rel; do
  case "$rel" in ''|\#*) continue ;; esac
  f="$REPO/patches/$rel"
  [ -f "$f" ] || { echo "  MISSING  $rel"; continue; }
  if [ "$DRY" = "--dry-run" ]; then
    if patch -p1 --forward --fuzz=3 --dry-run -d "$TREE" < "$f" >/dev/null 2>&1; then
      echo "  ok(dry) $rel"; ok=$((ok+1))
    else echo "  REJECT  $rel"; rej=$((rej+1)); fi
  else
    out=$(patch -p1 --forward --fuzz=3 -d "$TREE" < "$f" 2>&1)
    if   echo "$out" | grep -q 'FAILED\|saving rejects'; then echo "  REJECT  $rel"; rej=$((rej+1))
    elif echo "$out" | grep -q 'previously applied';      then echo "  already $rel"; skip=$((skip+1))
    else echo "  ok      $rel"; ok=$((ok+1)); fi
  fi
done < "$SERIES"
echo "== $ok ok, $skip already, $rej reject =="
[ "$rej" -eq 0 ]
