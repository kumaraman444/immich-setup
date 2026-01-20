#!/usr/bin/env bash
set -e
source .env

echo "🔒 Pre-eject safety check"

lsof | grep "/Volumes/${DISK_NAME}" && {
  echo "❌ Disk is still in use"
  exit 1
}

echo "✅ Disk is safe to eject"
