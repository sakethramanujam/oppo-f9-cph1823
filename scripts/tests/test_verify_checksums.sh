#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo hello >"$TMP/a.bin"
(cd "$TMP" && sha256sum a.bin >SHA256SUMS)
"$ROOT/scripts/verify-checksums.sh" "$TMP"
echo bye >"$TMP/a.bin"
if "$ROOT/scripts/verify-checksums.sh" "$TMP"; then
  echo "expected checksum failure" >&2
  exit 1
fi
echo "test_verify_checksums OK"
