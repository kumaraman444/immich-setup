#!/usr/bin/env bash
set -e
source .env

if [ -z "$1" ]; then
  echo "Usage: ./scripts/restore-db.sh <backup-file.sql>"
  exit 1
fi

BACKUP_FILE="/Volumes/${DISK_NAME}/${DISK_SHARE}/immich/backups/$1"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Backup file not found: $BACKUP_FILE"
  exit 1
fi

docker exec -i immich_postgres psql -U ${DB_USERNAME} < "$BACKUP_FILE"

echo "✅ Database restored from $1"
