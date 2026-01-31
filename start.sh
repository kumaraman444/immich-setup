#!/usr/bin/env bash
set -euo pipefail

# start.sh - prepares mounts, starts services and optionally restores latest DB backup

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Missing $ENV_FILE; create it from .env.example first." >&2
    exit 1
fi

# Load key variables from .env (without sourcing to avoid $$ expansion issues)
UPLOAD_LOCATION=$(grep '^UPLOAD_LOCATION=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
BACKUP_LOCATION=$(grep '^BACKUP_LOCATION=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
DB_USERNAME=$(grep '^DB_USERNAME=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
DB_DATABASE_NAME=$(grep '^DB_DATABASE_NAME=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
DB_PASSWORD_RAW=$(grep '^DB_PASSWORD=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
# .env uses $$ to escape $ for docker-compose; convert double-dollar to single-dollar for runtime usage
DB_PASSWORD=$(printf '%s' "$DB_PASSWORD_RAW" | sed 's/\$\$/\$/g')

: "${UPLOAD_LOCATION:?UPLOAD_LOCATION not set in .env}"
: "${BACKUP_LOCATION:?BACKUP_LOCATION not set in .env}"

echo "🔎 Ensuring mount paths exist: $UPLOAD_LOCATION and $BACKUP_LOCATION"
sudo mkdir -p "$UPLOAD_LOCATION" "$BACKUP_LOCATION"
sudo chmod -R 755 "$(dirname "$UPLOAD_LOCATION")" || true
sudo chmod -R 755 "$UPLOAD_LOCATION" "$BACKUP_LOCATION"

echo "🚀 Starting database container"
docker compose up -d database

echo "⏳ Waiting for Postgres to accept connections..."
# wait for pg_isready
until docker exec immich_postgres pg_isready -U "$DB_USERNAME" >/dev/null 2>&1; do
    sleep 2
done

echo "✅ Postgres is ready"

# Find latest backup (sql or sql.gz)
LATEST_BACKUP=$(ls -t "$BACKUP_LOCATION"/*.sql* 2>/dev/null | head -1 || true)
if [ -n "$LATEST_BACKUP" ]; then
    echo "🔄 Restoring DB from $LATEST_BACKUP..."
    if [[ "$LATEST_BACKUP" == *.gz ]]; then
        gunzip -c "$LATEST_BACKUP" | docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME"
    else
        cat "$LATEST_BACKUP" | docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME"
    fi
    echo "✅ Restore finished"
else
    echo "ℹ️ No backup found at $BACKUP_LOCATION; skipping restore"
fi

echo "➡️ Starting remaining services"
docker compose up -d
echo "🎉 Immich should be available at http://localhost:2283"
