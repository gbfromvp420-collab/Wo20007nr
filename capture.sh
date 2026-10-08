#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p bash -c 'test -n "${CAPTURE_URL:-}" || { echo "Set CAPTURE_URL." >&2; exit 1; }'
/usr/bin/time -p bash -c 'test -n "${CAPTURE_DIR:-}" || { echo "Set CAPTURE_DIR." >&2; exit 1; }'
/usr/bin/time -p mkdir -p "${CAPTURE_DIR:?}"
/usr/bin/time -p bash -c 'case "${CAPTURE_DIR:?}" in "$PWD"|"$PWD"/*) echo "CAPTURE_DIR must be outside the project source." >&2; exit 1;; esac'
/usr/bin/time -p node "${RUNTIME_DIR:?}/scripts/default-capture.mjs"
