#!/bin/bash
# Script zum Prüfen und Einrichten der Cursor Workspace-Storage
# Für Multi-Computer Multi-User Setup

set -e

WORKSPACE_PATH="${1:-/Users/hpcn/n8n-workflows}"
CURRENT_USER=$(whoami)
CURSOR_STORAGE_BASE="$HOME/Library/Application Support/Cursor/User/workspaceStorage"

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "Cursor Workspace-Storage prüfen"
echo "=========================================="
echo ""
echo "📁 Workspace-Pfad: $WORKSPACE_PATH"
echo "👤 Aktueller Benutzer: $CURRENT_USER"
echo ""

# Prüfe ob Workspace existiert
if [ ! -d "$WORKSPACE_PATH" ]; then
    echo "❌ Fehler: Workspace-Verzeichnis nicht gefunden: $WORKSPACE_PATH"
    exit 1
fi

# Berechne Hash für Workspace-Pfad
WORKSPACE_HASH=$(python3 -c "import hashlib; print(hashlib.sha256(b'$WORKSPACE_PATH').hexdigest())")
echo "🔑 Workspace-Hash: ${WORKSPACE_HASH:0:16}..."
echo ""

# Prüfe ob Workspace-Storage existiert
STORAGE_PATH="$CURSOR_STORAGE_BASE/$WORKSPACE_HASH"
if [ -d "$STORAGE_PATH" ]; then
    echo -e "${GREEN}✅ Workspace-Storage gefunden:${NC}"
    echo "   $STORAGE_PATH"
    echo ""
    echo "📊 Inhalt:"
    ls -la "$STORAGE_PATH" | head -10
    echo ""
    
    # Prüfe ob state.vscdb existiert (enthält Chat-Historie)
    if [ -f "$STORAGE_PATH/state.vscdb" ]; then
        DB_SIZE=$(du -h "$STORAGE_PATH/state.vscdb" | cut -f1)
        echo -e "${GREEN}✅ Chat-Datenbank gefunden (Größe: $DB_SIZE)${NC}"
    else
        echo -e "${YELLOW}⚠️  Chat-Datenbank nicht gefunden${NC}"
    fi
    
    # Prüfe workspace.json
    if [ -f "$STORAGE_PATH/workspace.json" ]; then
        echo -e "${GREEN}✅ Workspace-Konfiguration gefunden${NC}"
        echo "   Inhalt:"
        cat "$STORAGE_PATH/workspace.json" 2>/dev/null | head -3
    fi
else
    echo -e "${YELLOW}⚠️  Workspace-Storage nicht gefunden${NC}"
    echo "   Erwarteter Pfad: $STORAGE_PATH"
    echo ""
    echo "ℹ️  Die Workspace-Storage wird automatisch erstellt, wenn du:"
    echo "   1. Cursor öffnest"
    echo "   2. File → Open Folder → $WORKSPACE_PATH auswählst"
    echo ""
    echo "   Oder: Doppelklicke auf den Workspace-Ordner im Finder"
    echo ""
    
    # Zeige andere Workspace-Storages
    echo "📋 Andere Workspace-Storages:"
    ls -1 "$CURSOR_STORAGE_BASE" 2>/dev/null | head -5 || echo "   Keine gefunden"
fi

echo ""
echo "=========================================="
echo "Multi-Computer Setup Info"
echo "=========================================="
echo ""
echo "📝 Wichtige Informationen:"
echo ""
echo "1. Workspace-Pfad: $WORKSPACE_PATH"
echo "   → Hash: $WORKSPACE_HASH"
echo ""
echo "2. Für andere Benutzer auf diesem Rechner:"
echo "   - Verwende den gleichen Workspace-Pfad"
echo "   - Cursor erstellt automatisch Workspace-Storage"
echo "   - Chats sind getrennt (pro Benutzer)"
echo ""
echo "3. Für andere Rechner:"
echo "   - Workspace-Pfad kann unterschiedlich sein"
echo "   - Hash wird unterschiedlich sein"
echo "   - Für gemeinsame Chats: Siehe CURSOR-MULTI-COMPUTER-SETUP.md"
echo ""
echo "4. Dokumentation:"
echo "   - docs/setup/CURSOR-MULTI-COMPUTER-SETUP.md"
echo "   - docs/setup/move-to-shared.sh"
echo ""

