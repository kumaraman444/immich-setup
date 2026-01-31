📸 Immich Self-Hosted (External Drive Setup)

This repository contains the configuration for running Immich on macOS using Colima and storing all data on an external SanDisk drive.
🛠 Prerequisites

    Docker Desktop or Colima: (Colima is recommended for performance on macOS).

    External Drive: SanDisk (or any drive) formatted for Mac, mounted at /Volumes/SanDisk.

    Folder Structure: Create the base folder: /Volumes/SanDisk/immich/upload.

🚀 First-Time Setup
1. Initialize Colima

Ensure Colima is started with write permissions for your external drive:
```bash
colima start --mount /Volumes:w --mount-type 9p
```
2. Configure Environment

Create a .env file in this directory and populate it with your credentials:

    DB_PASSWORD: A strong password for Postgres.

    DB_USERNAME: Your DB user (e.g., postgres).

    DB_DATABASE_NAME: Your DB name (e.g., immich).

    IMMICH_VERSION: Set to release.

3. Launch Immich
```bash
docker compose up -d
```
Access the UI at: http://localhost:2283
🔄 Migration (Restoring from Backup)

If you move to a new machine or need to rebuild your stack, follow these steps to restore your data from your SanDisk backups.
Step 1: Prepare the New Environment

    Plug your SanDisk drive into the new machine.

    Install Colima/Docker.

    Ensure your docker-compose.yml and .env files are present.

Step 2: Start Only the Database

We need the database running but "empty" before we can pour the backup into it.
```bash
docker compose up -d database
```
Step 3: Run the Restore Command

Locate your latest backup file in /Volumes/SanDisk/immich/postgres_backups/. Use the following command to restore (replace YOUR_BACKUP_FILE.sql.gz with your actual filename):
Bash

# Unzip the backup first
gunzip < /Volumes/SanDisk/immich/postgres_backups/YOUR_BACKUP_FILE.sql.gz | docker exec -i immich_postgres psql -U postgres -d immich

Step 4: Start Everything Else

Once the database is restored, start the rest of the services:
```bash
docker compose up -d
```
⚠️ Troubleshooting & Maintenance
Permission Issues (macOS)

If the server crashes with "Permission Denied" or "Folder Check" errors:

    Check your .env for IMMICH_IGNORE_MOUNT_CHECK_ERRORS=true.

    Ensure you used the :w flag when starting Colima.

Manual Backup

The system backs up daily to your SanDisk. To run one manually now:
```bash
docker exec immich_db_backup /backup.sh
```
Checking Logs

```bash
docker logs -f immich_server
```

## ⏪ How to Restore the Database
1. **Stop Immich Server**:
   `docker stop immich_server`

2. **Restore Command**:
   ```bash
   gunzip < /Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql | docker exec -i immich_postgres psql -U postgres -d immich