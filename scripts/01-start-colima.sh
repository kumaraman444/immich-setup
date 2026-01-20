#!/usr/bin/env bash
set -e
source .env

HOST_PATH="/Volumes/${DISK_NAME}/${DISK_SHARE}"

if [ ! -d "$HOST_PATH" ]; then
  echo "❌ $HOST_PATH does not exist"
  exit 1
fi

echo "🚀 Starting Colima (QEMU + sshfs, writable)"

colima stop || true

colima start \
  --vm-type=qemu \
  --mount-type=sshfs \
  --mount "${HOST_PATH}:${VM_MOUNT}:w" \
  --save-config
