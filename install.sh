#!/usr/bin/env bash
set -e

echo "🚀 Immich macOS installer"

command -v brew >/dev/null || {
  echo "❌ Homebrew not found. Install it first."
  exit 1
}

brew install colima docker qemu

chmod +x scripts/*.sh

./scripts/00-check-prereqs.sh
./scripts/01-start-colima.sh
./scripts/02-verify-mount.sh
./scripts/03-init-storage.sh
./scripts/04-start-immich.sh

echo "✅ Immich is running at http://localhost:2283"
