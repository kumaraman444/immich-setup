# 📸 Immich Self-Hosted (External Drive Setup)

Portable photo server setup for macOS using Docker/Colima with all data on an external drive.

## 🛠 Prerequisites

- **Colima** (recommended) or Docker Desktop
- External drive mounted at `/Volumes/SanDisk` (or update paths in `.env`)
- Copy `.env.example` to `.env` and fill in your values

## 🔐 Security & Credentials

- `.env` — runtime secrets (DO NOT commit; already in `.gitignore`)
- `.env.example` — template with required fields
- `CREDENTIALS.md` — password encryption and rotation guidance

**Important**: 
- Use a strong password (16+ chars, mixed case, numbers, symbols)
- If your password contains `$`, escape it as `$$` in `.env` for Docker Compose

## ⚡ Quick Start

1. Plug in external drive (mounted at `/Volumes/SanDisk`)
2. Copy `.env.example` to `.env` and update values
3. Start services and restore latest backup (if available):

```bash
./start.sh
```

**What `start.sh` does:**
- Ensures upload and backup directories exist with correct permissions
- Starts the database and waits for it to be ready
- Restores latest backup from the drive (if present)
- Starts remaining services

To stop services and save a timestamped backup:

```bash
./stop.sh
```

## Manual Setup / Restore

Start only the database:

```bash
docker compose up -d database
```

Quick restore (backup is usually gzipped):

```bash
gunzip < /Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql | docker exec -i immich_postgres psql -U postgres -d immich
```

Full restore (recommended when moving to a new Mac or rebuild from scratch):

```bash
docker-compose down && \
docker-compose up -d database && \
sleep 15 && \
docker exec immich_postgres psql -U postgres -c "DROP DATABASE IF EXISTS immich" && \
docker exec immich_postgres psql -U postgres -c "CREATE DATABASE immich" && \
gunzip < /Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql | docker exec -i immich_postgres psql -U postgres -d immich && \
docker-compose up -d
```

> Constraint/role errors during restore are usually resolved by the full restore path, which recreates an empty database first.

## ⚠️ Troubleshooting

### Colima Mount Issues

If you see `not a directory` or mount permission errors:

```bash
# Restart Colima with write access to /Volumes
colima stop
colima start --mount /Volumes:w --mount-type 9p
docker compose up -d
```

> Note: `9p` is only available with QEMU; Colima on Apple Silicon uses `virtiofs` automatically.

### Manual Backup

To trigger a backup immediately (if the backup service is running):

```bash
docker exec immich_db_backup /backup.sh
```

### View Logs

```bash
# Server logs
docker logs -f immich_server

# Database logs
docker logs -f immich_postgres
```

## 📋 Backup Details

- **Frequency**: Every 4 hours (configured in `docker-compose.yml`)
- **Retention**: 7 days
- **Location**: `/Volumes/SanDisk/immich/postgres_backups/`
- **Latest**: `/Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql`

## 📁 Project Files

- `docker-compose.yml` — service definitions and backup job configuration
- `.env` / `.env.example` — runtime environment variables
- `start.sh` / `stop.sh` — helper scripts for portable startup/shutdown
- `CREDENTIALS.md` — secure password storage and rotation guide
- `README.md` — this file