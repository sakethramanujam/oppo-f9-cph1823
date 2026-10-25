#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:?usage: dump-partitions.sh <backup-dir>}"
echo "Power off phone, short BROM test points, then connect USB." >&2
mkdir -p "$OUT"
# shellcheck disable=SC1091
source "$ROOT/.venv/bin/activate"
PARTS=(preloader lk lk2 boot recovery logo nvram nvdata protect1 protect2 proinfo seccfg vbmeta dtbo)
cd "$OUT"
for p in "${PARTS[@]}"; do
  echo "Dumping $p (skip if missing on device)..."
  mtk r "$p" "${p}.bin" || echo "WARN: skip $p" >&2
done
sha256sum ./*.bin >SHA256SUMS 2>/dev/null || true
echo "Dump complete under $OUT"
