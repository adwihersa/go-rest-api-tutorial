#!/usr/bin/env bash
# Apply all pending "up" migrations.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATIONS_DIR="$ROOT_DIR/migrations"

# Load DATABASE_URL (and other vars) from .env if present.
if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "error: DATABASE_URL is not set (define it in .env or the environment)" >&2
  exit 1
fi

# Optional step count, e.g. ./scripts/migrate-up.sh 1
migrate -path "$MIGRATIONS_DIR" -database "$DATABASE_URL" up "$@"
