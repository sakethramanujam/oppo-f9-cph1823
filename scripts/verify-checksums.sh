#!/usr/bin/env bash
set -euo pipefail
DIR="${1:?usage: verify-checksums.sh <backup-dir>}"
cd "$DIR"
sha256sum -c SHA256SUMS
