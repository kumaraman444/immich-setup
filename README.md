# Immich on macOS using Colima + External SSD

This repository provides a **stable, reproducible, and portable** way to run **Immich** on **macOS** using **Colima** and an **external SSD**, without Docker Desktop.

It is designed specifically to avoid common macOS + Docker filesystem issues.

---

## What this setup does

- Runs **Immich** on macOS using **Colima**
- Stores **photos, videos, thumbnails, and encoded media** on an **external SSD**
- Runs **Postgres inside the Colima VM** using a Docker named volume (for stability)
- Works across multiple Macs with the same external SSD
- No Docker Desktop required

---

## Architecture Overview (Important)

| Component | Location | Reason |
|--------|---------|------|
| Photos & Videos | External SSD | Large, portable storage |
| Thumbnails & Encoded Media | External SSD | Same lifecycle as media |
| Postgres Database | Docker named volume (inside Colima VM) | Required for stability |
| Colima VM | Internal disk | Disposable |
| Setup scripts | GitHub repository | Reproducible setup |

---

## Why Postgres is NOT on the external SSD

On macOS, Colima mounts host directories into the VM using **sshfs / virtiofs**.

While this works well for **media files**, it does **not** work reliably for **Postgres**.

### Reasons:
- Postgres requires strict POSIX ownership semantics (`chown`, `fchown`)
- sshfs does not fully support these operations
- This causes restart loops, permission errors, and corruption risk

### Correct approach:
- Media → external SSD
- Postgres → Docker named volume inside the VM

This is **intentional and required** for a stable setup.

---

## Requirements

- macOS
- Homebrew
- External SSD formatted as **APFS**

---

## First-time setup

### 1. Install required tools

```bash
brew install colima docker qemu
```

### 2. Clone the repository

```bash
git clone https://github.com/kumaraman444/immich-setup.git
cd immich-setup
```

### 3. Make scripts executable (one-time)

```bash
chmod +x scripts/*.sh
```

### 4. Create environment file

```bash
cp .env.example .env
```
#### Edit only if your disk name differs:
```bash
DISK_NAME=SandDisk
```


### 5. Run scripts in order (IMPORTANT)

```bash
git clone https://github.com/kumaraman444/immich-setup.git
cd immich-setup
```


### 2. Clone the repository

```bash
./scripts/00-check-prereqs.sh
./scripts/01-start-colima.sh
./scripts/02-verify-mount.sh
./scripts/03-init-storage.sh   # run only on first setup
./scripts/04-start-immich.sh
```

Open Immich in your browser:
```bash
http://localhost:2283
```

## Verifying the setup
### Check media is on the external SSD
```bash
docker exec immich_server ls /data
```
Should match:

```bash
ls /Volumes/SandDisk/colima-share/immich/library
```
Upload a photo and verify disk usage increases:
```bash
df -h /Volumes/SandDisk
```


## Check Postgres is healthy

```bash 
docker ps | grep immich_postgres
```

### Troubleshooting & Notes
#### If Postgres keeps restarting

Ensure `docker-compose.yaml` uses a named volume:
```bash
volumes:
  - postgres-data:/var/lib/postgresql/data
```
❌ Do NOT mount Postgres to /mnt/sandisk.

### How to check disk mounts
Inside the Colima VM:

```bash
colima ssh
ls /mnt/sandisk
exit
```

Inside Docker:
```bash
docker exec immich_server ls /data
```
On macOS:
```bash
ls /Volumes/SandDisk
```
All three should be consistent.

## MacOS Finder quirks (/Volumes)

#### macOS may leave stale folders under /Volumes even after a disk is ejected.

### Source of truth:

```bash
diskutil list
```

If the disk does not appear there, it is already ejected — even if /Volumes/SandDisk exists.

Stale folders can be safely removed:

```bash
sudo rm -rf /Volumes/SandDisk
```

## Safely stopping and ejecting the SSD

### Always stop services before unplugging the disk.

```bash
./scripts/stop-all.sh
```
(Optional check):
```bash
lsof | grep /Volumes/SandDisk
```
Eject safely:

```bash
diskutil list
diskutil eject /dev/diskX
```


# Migrating to another Mac

1. Install Homebrew
2. Install dependencies:
```bash
brew install colima docker qemu
```
3. Plug in the external SSD
4. Clone this repository
5. Grant Full Disk Access to:
    * Terminal
    * Docker
    * colima
    * sshfs
    * qemu-system-aarch64

Run:

```bash
./scripts/01-start-colima.sh
./scripts/02-verify-mount.sh
./scripts/04-start-immich.sh
```

Media appears immediately; database starts cleanly.

## Key takeaways
* External SSD is for media only
* Postgres must run inside the VM
* This setup avoids macOS filesystem bugs
* Designed for stability and portability


## Disclaimer
This setup reflects real-world macOS constraints, not theoretical Docker behavior.
It prioritizes data safety and reliability over shortcuts.