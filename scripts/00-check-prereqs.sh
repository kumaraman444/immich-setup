#!/usr/bin/env bash
set -e

for cmd in colima docker; do
  command -v $cmd >/dev/null || {
    echo "❌ $cmd not installed"
    exit 1
  }
done

echo "✅ Prerequisites OK"