# 🔐 Credentials Management & Security

This file documents how to securely manage your Immich credentials.

## Current Credentials

> **⚠️ DO NOT COMMIT THE ACTUAL .env FILE TO GIT**

### Database Credentials
- **Username**: `immich_user`
- **Password**: Stored in `.env` (encrypted locally)
- **Database**: `immich`

## Security Best Practices

### 1. **Keep .env File Locally Only**

The `.env` file is already in `.gitignore` and should NEVER be committed to git.

```bash
# Verify .env is ignored
cat .gitignore  # Should contain .env
```

### 2. **Encrypt Your Credentials (Recommended)**

For maximum security, especially if backing up to the cloud, encrypt your .env file locally:

#### Option A: GPG Encryption (Recommended)

```bash
# Encrypt .env file
gpg -c .env
# Enter a passphrase when prompted

# This creates .env.gpg (encrypted)
# Keep the encrypted file in git if needed, but never the plain .env
```

To decrypt:
```bash
gpg -d .env.gpg > .env
```

#### Option B: OpenSSL Encryption

```bash
# Encrypt .env
openssl enc -aes-256-cbc -salt -in .env -out .env.enc

# Decrypt .env
openssl enc -aes-256-cbc -d -in .env.enc > .env
```

#### Option C: Git-Crypt (For Team Collaboration)

```bash
# Initialize git-crypt in the repository
git-crypt init

# Encrypt .env file
echo ".env filter=git-crypt diff=git-crypt" >> .gitattributes
git-crypt add-gpg-user YOUR_GPG_KEY_ID
```

### 3. **Strong Password Requirements**

Your database password should be:
- ✅ At least 16 characters long
- ✅ Mix of uppercase and lowercase letters
- ✅ Include numbers and special characters (!@#$%^&*)
- ✅ Not based on dictionary words
- ✅ Never reused across services

**Current password**: `P7$mK2xL9@qR4vN8jE5wQ1bF6yU3hZ0cD` (example - generate your own)

### 4. **Backup Security**

Your database backups are stored at:
```
/Volumes/SanDisk/immich/postgres_backups/
```

**Security considerations:**
- Keep the SanDisk drive encrypted (use FileVault 2 on Mac)
- Store in a safe location when not in use
- Restrict permissions:
  ```bash
  chmod 700 /Volumes/SanDisk/immich/postgres_backups/
  ```

### 5. **If You Suspect a Compromise**

1. **Generate a new password immediately**:
   ```bash
   # Edit .env
   nano .env
   # Change DB_PASSWORD to a new strong password
   ```

2. **Update the database**:
   ```bash
   docker exec immich_postgres psql -U postgres -c "ALTER USER immich_user WITH PASSWORD 'NEW_STRONG_PASSWORD';"
   ```

3. **Restart services**:
   ```bash
   docker-compose down && docker-compose up -d
   ```

4. **If moving to a new machine**, ensure the old machine's .env is securely deleted:
   ```bash
   shred -u .env  # Securely delete on Mac
   ```

## Setup Instructions for New Machines

1. **Do NOT copy the plain .env file**
2. **Instead**: 
   - Copy `.env.example` and rename to `.env`
   - Ask for the encrypted credentials file (.env.gpg or similar)
   - Decrypt it locally:
     ```bash
     gpg -d .env.gpg >> .env
     ```
   - Delete the decrypted file when done with setup

## Storing in Cloud Backup

If you backup to cloud storage (OneDrive, iCloud, etc.):
- Store `.env.gpg` (encrypted version) only
- Keep the encryption key/passphrase in a password manager (1Password, Bitwarden, etc.)
- **Never** upload the plain `.env` file

## Password Manager Integration

Consider storing your database password in a password manager:
- **1Password**: Supports secure vaults
- **Bitwarden**: Open-source and self-hostable
- **KeePass**: Local-only password manager

Example with 1Password CLI:
```bash
# Store password
op item create --category password --title "Immich DB" --password "P7$mK2xL9@qR4vN8jE5wQ1bF6yU3hZ0cD"

# Retrieve password
op item get "Immich DB" --fields password
```

## Rotation Schedule

For production systems, consider rotating passwords:
- Every 90 days for high-security environments
- Every 6 months for personal setups
- Immediately if compromised

To rotate:
1. Generate new password
2. Update `.env`
3. Update database with new password
4. Restart services
5. Keep old password documented (in case of rollback needed)

## Checklist

- [ ] `.env` file is in `.gitignore`
- [ ] `.env.example` is committed to git (without secrets)
- [ ] `.env` is encrypted locally (optional but recommended)
- [ ] Strong password is used (16+ chars, mixed types)
- [ ] Backup location is secured (encrypted drive)
- [ ] Only authorized users have access to encrypted credentials
- [ ] Password manager setup (optional but recommended)
