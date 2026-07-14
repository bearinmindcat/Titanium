#!/usr/bin/env bash
# Add a NEW patch to the layer: copy a .patch into patches/<vendor>/ + append to series.
# Usage: tools/create-from-patch.sh <vendor> /path/to/some.patch
#   vendor = cromite | titanium/<area> | core/... | extra/... | <new-source>
# Series entries are relative to patches/ (buildkit format), e.g. "cromite/Foo.patch".
set -uo pipefail
VENDOR="${1:?usage: create-from-patch.sh <vendor> <patch-file>}"
SRC="${2:?need patch file}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$SRC" ] || { echo "no such patch: $SRC"; exit 1; }
mkdir -p "$REPO/patches/$VENDOR"
b="$(basename "$SRC")"; rel="$VENDOR/$b"            # series path is relative to patches/
cp "$SRC" "$REPO/patches/$rel"
grep -qxF "$rel" "$REPO/patches/series" || echo "$rel" >> "$REPO/patches/series"
echo "added patches/$rel + appended to series (validate with devutils/validate_patches.py)"
