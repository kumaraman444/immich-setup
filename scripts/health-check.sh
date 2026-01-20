#!/usr/bin/env bash
set -e
source .env

echo "🔍 Immich Health Check"

echo "▶ Docker containers:"
docker ps | grep immich || echo "❌ Immich containers not running"

echo "▶ Colima status:"
colima status

echo "▶ External disk mount:"
ls /Volumes/${DISK_NAME} >/dev/null \
  && echo "✅ Disk mounted" \
  || echo "❌ Disk NOT mounted"

echo "▶ VM mount:"
colima ssh ls ${VM_MOUNT} >/dev/null \
  && echo "✅ VM mount OK" \
  || echo "❌ VM mount missing"

echo "▶ Media directory:"
docker exec immich_server ls /data >/dev/null \
  && echo "✅ Media accessible" \
  || echo "❌ Media not accessible"

echo "✅ Health check completed"
