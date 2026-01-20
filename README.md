# Immich on macOS using Colima + External SSD

## What this does
- Runs Immich on macOS
- Stores photos + Postgres on an external SSD
- Fully portable across Macs
- No Docker Desktop required

## Requirements
- macOS
- Homebrew
- External APFS disk

## First-time setup

### 1. Install tools
```bash
brew install colima docker
brew install qemu
```

## Note:

* What to do if Postgres restarts (confirm named volume setup)
* How to check disk mounts (colima ssh && ls /mnt/sandisk)
* macOS Finder quirks (/Volumes showing stale folders)