#!/usr/bin/env bash
set -e

echo "Stopping services…"
docker compose down || true
colima stop || true

echo "Ejecting disk…"
diskutil list | grep external
echo "Use the identifier above to eject manually:"
echo "  diskutil eject /dev/diskX"

echo "✅ Disk is now safe to unplug"
