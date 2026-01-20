#!/usr/bin/env bash
set -e

BACKUP_DIR="/Volumes/${DISK_NAME}/${DISK_SHARE}/immich/backups"
mkdir -p "$BACKUP_DIR"

docker exec immich_postgres pg_dumpall -U ${DB_USERNAME} > "${BACKUP_DIR}/immich_db_$(date +%F).sql"

echo "📦 Backup saved to $BACKUP_DIR"
