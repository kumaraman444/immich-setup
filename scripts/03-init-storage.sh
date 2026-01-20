#!/usr/bin/env bash
set -e
source .env

BASE="/Volumes/${DISK_NAME}/${DISK_SHARE}/immich"

mkdir -p \
  "$BASE/library"/{upload,thumbs,encoded-video,library,profile,backups} \
  "$BASE/postgres"

for d in upload thumbs encoded-video library profile backups; do
  touch "$BASE/library/$d/.immich"
done

echo "✅ Immich storage initialized on external SSD"
