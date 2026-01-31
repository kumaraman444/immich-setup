gunzip < /Volumes/SanDisk/immich/postgres_backups/YOUR_BACKUP_FILE.sql.gz | docker exec -i immich_postgres psql -U postgres -d immich
gunzip < /Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql | docker exec -i immich_postgres psql -U postgres -d immich
# 📸 Immich Self-Hosted (External Drive Setup)

This repository provides a small, portable setup for running Immich on macOS using Docker/Colima with data stored on an external drive.

## 🛠 Prerequisites

- Docker Desktop or Colima (Colima recommended for macOS).
- External drive (example: SanDisk) mounted at `/Volumes/SanDisk`.
- Copy `.env.example` to `.env` and fill values before starting.

## 🔐 Security & Credentials

- `.env` — contains runtime secrets; do NOT commit this file.
- `.env.example` — template for required values.
- `CREDENTIALS.md` — how to securely store and rotate credentials.

Notes:
- Use a strong password (16+ characters, mixed case, numbers, symbols).
- If your password contains a dollar sign (`$`), escape it as `$$` in `.env` so Docker Compose treats it literally.

## Quick Start

1. Ensure your external drive is connected and mounted at `/Volumes/SanDisk`.
2. Create `.env` from `.env.example` and set your values.
3. Start Immich and restore the latest backup (if present):

```bash
./start.sh
```

This helper will:
- Ensure upload and backup folders exist on the external drive
- Start the database and wait until it is healthy
- Restore the latest backup from the drive (if available)
- Start the remaining services

To stop services and save a timestamped backup to the external drive:

```bash
./stop.sh
```

## Manual Migration / Restore

Start only the database:

```bash
docker compose up -d database
```

Quick restore (if backup is gzipped):

```bash
gunzip < /Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql | docker exec -i immich_postgres psql -U postgres -d immich
```

Full restore (use when schema/constraint issues occur):

```bash
docker-compose down && \
docker-compose up -d database && \
sleep 15 && \
docker exec immich_postgres psql -U postgres -c "DROP DATABASE IF EXISTS immich" && \
docker exec immich_postgres psql -U postgres -c "CREATE DATABASE immich" && \
gunzip < /Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql | docker exec -i immich_postgres psql -U postgres -d immich && \
docker-compose up -d
```

If you see constraint/role errors during restore, the full restore path recreates an empty database first and usually resolves them.

## Troubleshooting & Notes

- If Docker/Colima cannot mount `/Volumes/SanDisk`, start Colima with mounts enabled:

```bash
colima start --mount /Volumes:w --mount-type 9p
```

- Manual backup trigger (if backup service is running):

```bash
docker exec immich_db_backup /backup.sh
```

## Backup Configuration

- Backup Frequency: every 4 hours (in `docker-compose.yml` via `SCHEDULE`).
- Retention: 7 days (`BACKUP_KEEP_DAYS`).
- Backup Path: `/Volumes/SanDisk/immich/postgres_backups/` with latest symlink at `/Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql`.

## Files of interest

- `docker-compose.yml` — services and backup job
- `.env` / `.env.example` — runtime config
- `start.sh` / `stop.sh` — helper scripts for portable startup/shutdown
- `CREDENTIALS.md` — secure storage and rotation instructions

Want me to run a quick lint/format check on this README or add a short Troubleshooting checklist for new machines?