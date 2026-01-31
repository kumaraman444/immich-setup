#!/usr/bin/env bash
set -euo pipefail

# start.sh - prepares mounts, starts services and optionally restores latest DB backup

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Missing $ENV_FILE; create it from .env.example first." >&2
    exit 1
fi

# Check if Docker/Colima is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Start Colima or Docker Desktop first." >&2
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

# Check if external drive is mounted, warn if not
if [[ "$UPLOAD_LOCATION" == /Volumes/* ]]; then
    DRIVE=$(echo "$UPLOAD_LOCATION" | cut -d'/' -f3)
    if [ ! -d "/Volumes/$DRIVE" ]; then
        echo "⚠️  Drive '/Volumes/$DRIVE' not mounted. Services may fail to start."
        echo "📌 Connect the drive or update UPLOAD_LOCATION in .env to use local paths."
        echo ""
    fi
fi

echo "🔎 Ensuring mount paths exist: $UPLOAD_LOCATION and $BACKUP_LOCATION"
sudo mkdir -p "$UPLOAD_LOCATION" "$BACKUP_LOCATION" 2>/dev/null || {
    echo "⚠️  Could not create directories (drive may not be connected)." >&2
    echo "    Will attempt to start with existing structure." >&2
}
sudo chmod -R 755 "$(dirname "$UPLOAD_LOCATION")" 2>/dev/null || true
sudo chmod -R 755 "$UPLOAD_LOCATION" "$BACKUP_LOCATION" 2>/dev/null || true

echo "🚀 Starting database container"
if ! docker compose up -d database; then
    echo "❌ Failed to start database. Check docker-compose.yml." >&2
    exit 1
fi

echo "⏳ Waiting for Postgres to accept connections..."
RETRY=0
MAX_RETRIES=30
until docker exec immich_postgres pg_isready -U "$DB_USERNAME" >/dev/null 2>&1; do
    RETRY=$((RETRY + 1))
    if [ $RETRY -ge $MAX_RETRIES ]; then
        echo "❌ Database failed to become ready after $MAX_RETRIES attempts." >&2
        exit 1
    fi
    sleep 2
done

echo "✅ Postgres is ready"

# Find latest backup (sql or sql.gz)
LATEST_BACKUP=$(ls -t "$BACKUP_LOCATION"/*.sql* 2>/dev/null | head -1 || true)
if [ -n "$LATEST_BACKUP" ]; then
    echo "🔄 Restoring DB from $LATEST_BACKUP..."
    if [[ "$LATEST_BACKUP" == *.gz ]]; then
        gunzip -c "$LATEST_BACKUP" | docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" 2>/dev/null || {
            echo "⚠️ Restore had errors (likely schema conflicts). Services starting anyway." >&2
        }
    else
        cat "$LATEST_BACKUP" | docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" 2>/dev/null || {
            echo "⚠️ Restore had errors (likely schema conflicts). Services starting anyway." >&2
        }
    fi
    echo "✅ Restore attempt finished"
else
    echo "ℹ️ No backup found at $BACKUP_LOCATION; skipping restore"
fi

echo "➡️ Starting remaining services"
docker compose up -d 2>/dev/null || {
    echo "❌ Failed to start services. Check docker-compose.yml." >&2
    exit 1
}

echo ""
echo "🎉 Immich services started!"
echo "✨ Access the UI at: http://localhost:2283"
echo "📊 Services: $(docker compose ps --services | wc -l) containers running"
