#!/bin/bash

# WireGuard Configuration Backup Script
# Automatically backs up WireGuard config with timestamp

BACKUP_DIR="./backups"
CONFIG_DIR="./wireguard-config"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="wireguard-backup-${TIMESTAMP}.tar.gz"

echo "🔄 Starting WireGuard backup..."

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create compressed backup
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" "${CONFIG_DIR}" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Backup completed successfully"
    echo "📁 Location: ${BACKUP_DIR}/${BACKUP_FILE}"
    echo "📊 Size: $(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)"
else
    echo "❌ Backup failed"
    exit 1
fi

# Keep only last 10 backups
echo "🧹 Cleaning old backups..."
cd $BACKUP_DIR
ls -t wireguard-backup-*.tar.gz | tail -n +11 | xargs -r rm

echo "✨ Backup completed!"
