#!/bin/bash
# Migrations-Script: Alte Struktur (n8n/workflow-name.json) → Neue Struktur (n8n/{workflowId}/{workflowName}.json)
# Führt bestehende Workflows in die neue ID-basierte Struktur um

set -e

N8N_DIR="n8n"
BACKUP_DIR="n8n-backup-$(date +%Y%m%d_%H%M%S)"

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "Migration zu ID-basierter Struktur"
echo "=========================================="
echo ""
echo "📁 Quell-Verzeichnis: $N8N_DIR"
echo "📦 Backup-Verzeichnis: $BACKUP_DIR"
echo ""

# Prüfe ob n8n-Verzeichnis existiert
if [ ! -d "$N8N_DIR" ]; then
    echo -e "${RED}❌ Fehler: Verzeichnis $N8N_DIR nicht gefunden!${NC}"
    exit 1
fi

# Zähle JSON-Dateien
JSON_COUNT=$(find "$N8N_DIR" -maxdepth 1 -name "*.json" -type f | wc -l | tr -d ' ')
echo "📊 Gefundene Workflow-Dateien: $JSON_COUNT"
echo ""

if [ "$JSON_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Keine Dateien zum Migrieren gefunden${NC}"
    exit 0
fi

# Erstelle Backup
echo "📦 Erstelle Backup..."
cp -r "$N8N_DIR" "$BACKUP_DIR"
echo -e "${GREEN}✅ Backup erstellt: $BACKUP_DIR${NC}"
echo ""

# Prüfe ob bereits ID-Ordner existieren
EXISTING_ID_DIRS=$(find "$N8N_DIR" -maxdepth 1 -type d -name "*" | grep -v "^$N8N_DIR$" | wc -l | tr -d ' ')
if [ "$EXISTING_ID_DIRS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warnung: Es existieren bereits $EXISTING_ID_DIRS Unterordner in $N8N_DIR${NC}"
    echo "   Möglicherweise wurde bereits migriert oder es gibt gemischte Struktur."
    read -p "   Trotzdem fortfahren? (j/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
        echo "Abgebrochen."
        exit 1
    fi
fi

echo "🔄 Starte Migration..."
echo ""

MIGRATED=0
ERRORS=0
SKIPPED=0

# Durchlaufe alle JSON-Dateien im n8n-Verzeichnis (nur erste Ebene)
find "$N8N_DIR" -maxdepth 1 -name "*.json" -type f | while read file; do
    filename=$(basename "$file")
    
    # Extrahiere Workflow-ID aus JSON
    workflow_id=$(python3 -c "
import json, sys
try:
    with open('$file') as f:
        data = json.load(f)
        wf_id = data.get('id', '')
        if wf_id:
            print(wf_id)
        else:
            # Versuche ID aus Nodes zu finden (für Backup-Workflows)
            for node in data.get('nodes', []):
                if node.get('id'):
                    # Verwende erste Node-ID als Fallback (nicht ideal, aber besser als nichts)
                    pass
            print('')
except Exception as e:
    print('')
" 2>/dev/null)
    
    if [ -z "$workflow_id" ]; then
        echo -e "${YELLOW}⚠️  Überspringe $filename (keine Workflow-ID gefunden)${NC}"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Extrahiere Workflow-Name
    workflow_name=$(python3 -c "
import json, sys
try:
    with open('$file') as f:
        data = json.load(f)
        name = data.get('name', 'Unnamed Workflow')
        # Bereinige Name für Dateinamen
        import re
        clean = re.sub(r'[^a-zA-Z0-9-_äöüÄÖÜß ]', '', name)
        clean = re.sub(r'\s+', '-', clean).lower()
        print(clean)
except:
    print('unnamed-workflow')
" 2>/dev/null)
    
    # Erstelle Ziel-Verzeichnis
    target_dir="$N8N_DIR/$workflow_id"
    target_file="$target_dir/$workflow_name.json"
    
    # Prüfe ob Ziel bereits existiert
    if [ -f "$target_file" ]; then
        echo -e "${YELLOW}⚠️  Überspringe $filename → $target_file (existiert bereits)${NC}"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Erstelle Verzeichnis
    mkdir -p "$target_dir"
    
    # Verschiebe Datei
    mv "$file" "$target_file"
    
    echo -e "${GREEN}✅ $filename → $target_file${NC}"
    MIGRATED=$((MIGRATED + 1))
done

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Migration abgeschlossen!${NC}"
echo "=========================================="
echo ""
echo "📊 Statistik:"
echo "   Migriert: $MIGRATED"
echo "   Übersprungen: $SKIPPED"
echo "   Fehler: $ERRORS"
echo ""
echo "📦 Backup: $BACKUP_DIR"
echo ""
echo "📝 Nächste Schritte:"
echo "1. Prüfe die neue Struktur:"
echo "   ls -la $N8N_DIR/"
echo ""
echo "2. Teste den Backup-Workflow in n8n"
echo ""
echo "3. Falls alles funktioniert, Backup löschen:"
echo "   rm -rf $BACKUP_DIR"
echo ""

