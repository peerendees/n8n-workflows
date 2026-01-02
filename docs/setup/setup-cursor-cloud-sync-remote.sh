#!/bin/bash
# Setup-Script für weitere Rechner/Benutzer
# Verwendung: ./setup-cursor-cloud-sync-remote.sh [WORKFLOW_ID] [CLOUD_PROVIDER] [LOCAL_WORKSPACE_PATH]
# Beispiel: ./setup-cursor-cloud-sync-remote.sh n8n-workflows-main icloud ~/n8n-workflows

set -e

WORKFLOW_ID="${1:-n8n-workflows-main}"
CLOUD_PROVIDER="${2:-icloud}"
LOCAL_WORKSPACE_PATH="${3:-$HOME/n8n-workflows}"

# Cloud-Verzeichnis bestimmen
case $CLOUD_PROVIDER in
  icloud)
    CLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Cursor-Workspaces"
    ;;
  dropbox)
    CLOUD_DIR="$HOME/Dropbox/Cursor-Workspaces"
    ;;
  onedrive)
    CLOUD_DIR="$HOME/OneDrive/Cursor-Workspaces"
    ;;
  *)
    echo "❌ Unbekannter Cloud-Provider: $CLOUD_PROVIDER"
    echo "Verfügbare Provider: icloud, dropbox, onedrive"
    exit 1
    ;;
esac

# Workspace-ID berechnen (muss identisch sein!)
WORKSPACE_ID=$(echo -n "$WORKFLOW_ID" | shasum -a 256 | cut -d' ' -f1)
LOCAL_HASH=$(python3 -c "import hashlib; print(hashlib.sha256(b'$LOCAL_WORKSPACE_PATH').hexdigest())")

echo "📋 Workflow-ID: $WORKFLOW_ID"
echo "🔑 Workspace-ID: $WORKSPACE_ID"
echo "📁 Lokaler Workspace-Pfad: $LOCAL_WORKSPACE_PATH"
echo "🔢 Lokaler Hash: $LOCAL_HASH"
echo "☁️  Cloud-Verzeichnis: $CLOUD_DIR"

# Prüfen ob Cloud-Verzeichnis existiert
if [ ! -d "$CLOUD_DIR/$WORKSPACE_ID" ]; then
    echo ""
    echo "⚠️  Cloud-Verzeichnis nicht gefunden: $CLOUD_DIR/$WORKSPACE_ID"
    echo ""
    echo "Mögliche Ursachen:"
    echo "1. Cloud-Sync ist nicht aktiviert oder noch nicht synchronisiert"
    echo "2. Erster Rechner/Benutzer hat Setup noch nicht durchgeführt"
    echo "3. Falscher Cloud-Provider angegeben"
    echo ""
    echo "Lösung:"
    echo "- Prüfe ob Cloud-Sync aktiv ist"
    echo "- Warte auf Synchronisation"
    echo "- Führe Setup auf erstem Rechner/Benutzer zuerst aus"
    exit 1
fi

echo ""
echo "✅ Cloud-Verzeichnis gefunden!"

# Symlinks erstellen
echo ""
echo "🔗 Erstelle Symlinks..."
mkdir -p "$HOME/Library/Application Support/Cursor/User/workspaceStorage"
ln -sf "$CLOUD_DIR/$WORKSPACE_ID" "$HOME/Library/Application Support/Cursor/User/workspaceStorage/$WORKSPACE_ID"
ln -sf "$CLOUD_DIR/$WORKSPACE_ID" "$HOME/Library/Application Support/Cursor/User/workspaceStorage/$LOCAL_HASH"
echo "✅ Symlinks erstellt"

echo ""
echo "✅ Setup abgeschlossen!"
echo ""
echo "📝 Nächste Schritte:"
echo "1. Öffne den Workspace in Cursor: $LOCAL_WORKSPACE_PATH"
echo "2. Die Chat-Historie sollte automatisch verfügbar sein"
echo ""
echo "⚠️  WICHTIG: Cursor sollte nicht gleichzeitig von mehreren Benutzern geöffnet werden!"

