#!/usr/bin/env bash
set -e
source .env

echo "🔍 Verifying mount inside Colima VM..."

colima ssh <<EOF
set -e
touch ${VM_MOUNT}/.mount_test
ls -l ${VM_MOUNT}
EOF

echo "✅ Mount is writable"
