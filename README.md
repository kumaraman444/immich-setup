# Immich Setup (Mac + Colima + External Drive)

This repository contains the configuration for a self-hosted Immich instance running on macOS using Colima and an external SandDisk drive for photo storage.
## 🚀 Quick Start
#### 1. Initialize Colima

Since the photo library is on an external drive, you must start Colima with the /Volumes folder mounted and writable. Run this command on your Mac terminal:
Bash

colima start --mount /Volumes:w

#### 2. Prepare Directory Permissions

Inside the Colima VM, the folder must be accessible by the Docker containers.
Bash

colima ssh "sudo mkdir -p /Volumes/SandDisk/immich/library && sudo chmod -R 777 /Volumes/SandDisk/immich"

#### 3. Launch Immich
```bash
docker compose up -d
```


Access the dashboard at: http://localhost:2283
📂 File Structure
.env
```bash
IMMICH_VERSION=release
```

# Path verified inside Colima VM
UPLOAD_LOCATION=/Volumes/SandDisk/immich/library

# Database credentials
DB_PASSWORD=postgres
DB_USERNAME=postgres
DB_DATABASE_NAME=immich
```bash
docker-compose.yml
```

Includes the IMMICH_DISABLE_CHOWN: "true" flag to prevent permission errors common with external drives on macOS.
## 🔄 Migration Guide (Moving to a New Mac)

To move this setup to a different computer while keeping all your users, albums, and faces:
#### Phase 1: On the Old Mac

Back up the database to your SandDisk:
    
```bash
docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres | gzip > /Volumes/SandDisk/immich/immich-db-backup.sql.gz
```
Copy your config files (.env and docker-compose.yml) to the SandDisk or a cloud drive.

#### Phase 2: On the New Mac

* Install Colima & Docker.
* Plug in the SandDisk.
* Start Colima with the volume mount: colima start --mount /Volumes:w.
* Place your config files in a new folder and run docker compose up -d.

Restore the database:
```bash
gunzip < /Volumes/SandDisk/immich/immich-db-backup.sql.gz | docker exec -i immich_postgres psql --username=postgres
```


Restart the containers:
```bash
    docker compose restart
```
## 🛠 Troubleshooting

    Storage reporting 57 TiB: This is a cosmetic bug in Colima's file-sharing system. It does not affect actual storage.

    Permission Denied: Run the chmod -R 777 command inside colima ssh again.

    Database failing: Ensure the postgres-data volume is on the Mac's internal drive (SSD) for performance.

For a visual walkthrough on managing these database dumps and understanding how Postgres handles users during a move, you can check out this Immich backup and restore guide. This video is helpful because it explains the specific pg_dumpall logic used in your migration process.