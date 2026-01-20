---

## Database Backup & Restore

Because Postgres runs inside the Colima VM (Docker named volume), backups are essential for portability and disaster recovery.

### Backup the database to the external SSD

Create a backup script:

```bash
./scripts/backup-db.sh
```

## This will generate a timestamped SQL dump on the external SSD:

/Volumes/<DISK_NAME>/<DISK_SHARE>/immich/backups/immich_db_YYYY-MM-DD.sql


# Restore the database from a backup

This will overwrite the existing database.

```bash
./scripts/restore-db.sh immich_db_YYYY-MM-DD.sql
```