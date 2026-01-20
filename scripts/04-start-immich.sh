#!/usr/bin/env bash
set -e

docker compose pull
docker compose up -d
diskutil eject /dev/diskX

echo "🚀 Immich running at http://localhost:2283"
