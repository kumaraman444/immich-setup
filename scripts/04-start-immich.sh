#!/usr/bin/env bash
set -e

docker compose pull
docker compose up -d

echo "🚀 Immich running at http://localhost:2283"
