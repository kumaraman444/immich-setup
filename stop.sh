#!/usr/bin/env bash
set -euo pipefail

# stop.sh - create timestamped backup to the SanDisk then stop services
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $ENV_FILE; create it from .env.example first." >&2
  exit 1
fi

BACKUP_LOCATION=$(grep '^BACKUP_LOCATION=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
DB_USERNAME=$(grep '^DB_USERNAME=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
DB_DATABASE_NAME=$(grep '^DB_DATABASE_NAME=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
DB_PASSWORD_RAW=$(grep '^DB_PASSWORD=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' || true)
DB_PASSWORD=$(printf '%s' "$DB_PASSWORD_RAW" | sed 's/\$\$/\$/g')

: "${BACKUP_LOCATION:?BACKUP_LOCATION not set in .env}"

echo "🔎 Ensuring backup path exists: $BACKUP_LOCATION"
sudo mkdir -p "$BACKUP_LOCATION"
sudo chmod -R 755 "$BACKUP_LOCATION"

TS=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_LOCATION/immich-$TS.sql.gz"

echo "📦 Creating backup to $BACKUP_FILE"
docker exec immich_postgres pg_dump -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" | gzip > "$BACKUP_FILE"
echo "✅ Backup saved: $BACKUP_FILE"

echo "🛑 Stopping services"
docker compose down

echo "Done."
