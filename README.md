📸 Immich Self-Hosted (External Drive Setup)

This repository contains the configuration for running Immich on macOS using Colima and storing all data on an external SanDisk drive.
🛠 Prerequisites

    Docker Desktop or Colima: (Colima is recommended for performance on macOS).

    External Drive: SanDisk (or any drive) formatted for Mac, mounted at /Volumes/SanDisk.

    Folder Structure: Create the base folder: /Volumes/SanDisk/immich/upload.

## 🔐 Security & Credentials

**IMPORTANT**: This repository includes credentials management files.

- **`.env`**: Contains your database password. **NEVER commit this to git**. It's already in `.gitignore`.
- **`.env.example`**: Template for creating your own `.env` file.
- **`CREDENTIALS.md`**: Comprehensive guide for securely managing passwords, encryption, and backups.

**Quick Security Checklist**:
1. ✅ Verify `.env` is in `.gitignore`
2. ✅ Use a strong password (16+ chars, mixed case, numbers, symbols)
3. ✅ Encrypt sensitive files for cloud backup (see `CREDENTIALS.md`)
4. ✅ Keep backup drive encrypted (FileVault 2 on Mac)

**See `CREDENTIALS.md` for**:
- Encrypting your credentials (GPG, OpenSSL, git-crypt)
- Password rotation schedules
- Compromised credentials recovery
- Secure setup on new machines

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

```bash
# Unzip the backup first
gunzip < /Volumes/SanDisk/immich/postgres_backups/YOUR_BACKUP_FILE.sql.gz | docker exec -i immich_postgres psql -U postgres -d immich
```

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

### Full Restore (Recommended - Use When Moving to Another Mac)

This command stops all services, drops the existing database, recreates it, restores the latest backup, and restarts everything:

```bash
docker-compose down && \
docker-compose up -d database && \
sleep 15 && \
docker exec immich_postgres psql -U postgres -c "DROP DATABASE IF EXISTS immich" && \
docker exec immich_postgres psql -U postgres -c "CREATE DATABASE immich" && \
gunzip < /Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql | docker exec -i immich_postgres psql -U postgres -d immich && \
docker-compose up -d
```

**Step-by-step what this does:**
1. Stops all containers
2. Starts only the database container
3. Waits 15 seconds for the database to be ready
4. Drops the existing immich database (if it exists)
5. Creates a fresh immich database
6. Restores the latest backup from your SanDisk drive
7. Restarts all services

### Quick Restore (Use When Database is Running)

If you only want to restore without dropping and recreating:

```bash
gunzip < /Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql | docker exec -i immich_postgres psql -U postgres -d immich
```

**Note:** This may fail if there are constraint conflicts. Use the full restore in that case.

## 📋 Backup Configuration

- **Backup Frequency**: Every 4 hours (`SCHEDULE: "0 */4 * * *"`)
- **Retention**: Backups are automatically kept for 7 days (`BACKUP_KEEP_DAYS: 7`)
- **Backup Location**: `/Volumes/SanDisk/immich/postgres_backups/`
- **Latest Symlink**: `/Volumes/SanDisk/immich/postgres_backups/last/immich-latest.sql`