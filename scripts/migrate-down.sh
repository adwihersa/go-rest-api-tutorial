#!/usr/bin/env bash
# Roll back migrations. By default rolls back the most recent migration (1 step).
# Pass a number to roll back N steps, or "all" to roll back everything.
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

# Describe what is about to happen so the confirmation is meaningful.
if [[ "${1:-}" == "all" ]]; then
  target="ALL migrations"
else
  steps="${1:-1}"
  target="$steps migration(s)"
fi

read -r -p "Roll back $target on this database? [y/N] " answer
case "$answer" in
  [yY] | [yY][eE][sS]) ;;
  *)
    echo "Aborted."
    exit 0
    ;;
esac

if [[ "${1:-}" == "all" ]]; then
  migrate -path "$MIGRATIONS_DIR" -database "$DATABASE_URL" down -all
else
  migrate -path "$MIGRATIONS_DIR" -database "$DATABASE_URL" down "$steps"
fi
