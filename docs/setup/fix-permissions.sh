#!/bin/bash
# Script zum Setzen der korrekten Berechtigungen
# Muss als Admin-Benutzer (z.B. adminku) ausgeführt werden

set -e

WORKSPACE_DIR="/Users/Shared/n8n-workflows"

echo "=========================================="
echo "Berechtigungen korrigieren"
echo "=========================================="
echo ""

if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "❌ Fehler: Workspace-Verzeichnis nicht gefunden: $WORKSPACE_DIR"
    exit 1
fi

echo "📁 Workspace: $WORKSPACE_DIR"
echo ""

# Benutzer für Owner-Berechtigung
# Primärer Benutzer: kunkel (falls vorhanden)
# Falls nicht vorhanden, automatisch ersten Benutzer erkennen
if [ -d "/Users/kunkel" ]; then
    OWNER_USER="kunkel"
else
    OWNER_USER=$(ls -1 /Users | grep -v "^Shared$" | grep -v "^Guest" | head -1)
    if [ -z "$OWNER_USER" ]; then
        OWNER_USER=$(whoami)
    fi
fi

echo "👤 Owner-Benutzer: $OWNER_USER"
echo ""

# Owner und Gruppe setzen
echo "🔐 Schritt 1: Setze Owner/Gruppe..."
sudo chown -R "$OWNER_USER:staff" "$WORKSPACE_DIR"
echo "✅ Owner/Gruppe gesetzt ($OWNER_USER:staff)"

# Verzeichnisse: 775 (rwxrwxr-x)
echo ""
echo "🔐 Schritt 2: Setze Verzeichnis-Berechtigungen (775)..."
sudo find "$WORKSPACE_DIR" -type d -exec chmod 775 {} \;
echo "✅ Verzeichnis-Berechtigungen gesetzt"

# Dateien: 664 (rw-rw-r--)
echo ""
echo "🔐 Schritt 3: Setze Datei-Berechtigungen (664)..."
sudo find "$WORKSPACE_DIR" -type f -exec chmod 664 {} \;
echo "✅ Datei-Berechtigungen gesetzt"

# Scripts ausführbar machen: 775
echo ""
echo "🔐 Schritt 4: Setze Script-Berechtigungen (775)..."
sudo find "$WORKSPACE_DIR" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod 775 {} \;
echo "✅ Script-Berechtigungen gesetzt"

# .git Verzeichnis: 775
if [ -d "$WORKSPACE_DIR/.git" ]; then
    echo ""
    echo "🔐 Schritt 5: Setze Git-Verzeichnis-Berechtigungen (775)..."
    sudo chmod -R 775 "$WORKSPACE_DIR/.git"
    echo "✅ Git-Verzeichnis-Berechtigungen gesetzt"
fi

echo ""
echo "=========================================="
echo "✅ Berechtigungen korrigiert!"
echo "=========================================="
echo ""
echo "Prüfe:"
echo "  stat -f \"%Sp %N\" $WORKSPACE_DIR"
echo "  stat -f \"%Sp %N\" $WORKSPACE_DIR/README.md"
echo ""

