#!/bin/bash

# Backup-Verzeichnis
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/threema_db_backup_$DATE.sql"

# Stelle sicher, dass das Backup-Verzeichnis existiert
mkdir -p "$BACKUP_DIR"

# Führe das Backup durch
echo "Starte Datenbank-Backup..."
docker-compose exec -T postgres pg_dump -U n8n_user threema_db > "$BACKUP_FILE"

# Komprimiere das Backup
gzip "$BACKUP_FILE"

# Lösche alte Backups (älter als 30 Tage)
find "$BACKUP_DIR" -name "threema_db_backup_*.sql.gz" -mtime +30 -delete

echo "Backup abgeschlossen: ${BACKUP_FILE}.gz" 