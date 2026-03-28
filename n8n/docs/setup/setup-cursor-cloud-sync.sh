#!/bin/bash
# Setup-Script für ersten Rechner/Benutzer
# Verwendung: ./setup-cursor-cloud-sync.sh [WORKFLOW_ID] [CLOUD_PROVIDER]
# Beispiel: ./setup-cursor-cloud-sync.sh n8n-workflows-main icloud

set -e

WORKFLOW_ID="${1:-n8n-workflows-main}"  # Workflow-ID als Parameter
CLOUD_PROVIDER="${2:-icloud}"  # icloud, dropbox, onedrive

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

# Workspace-ID berechnen
WORKSPACE_ID=$(echo -n "$WORKFLOW_ID" | shasum -a 256 | cut -d' ' -f1)
echo "📋 Workflow-ID: $WORKFLOW_ID"
echo "🔑 Workspace-ID: $WORKSPACE_ID"
echo "☁️  Cloud-Verzeichnis: $CLOUD_DIR"

# Aktuellen Workspace-Pfad ermitteln
CURRENT_WORKSPACE_PATH=$(pwd)
CURRENT_HASH=$(python3 -c "import hashlib; print(hashlib.sha256(b'$CURRENT_WORKSPACE_PATH').hexdigest())")
echo "📁 Aktueller Workspace-Pfad: $CURRENT_WORKSPACE_PATH"
echo "🔢 Aktueller Hash: $CURRENT_HASH"

# Cloud-Verzeichnis erstellen
echo ""
echo "📦 Erstelle Cloud-Verzeichnis..."
mkdir -p "$CLOUD_DIR/$WORKSPACE_ID"

# Workspace-Storage verschieben/kopieren
STORAGE_PATH="$HOME/Library/Application Support/Cursor/User/workspaceStorage/$CURRENT_HASH"
if [ -d "$STORAGE_PATH" ]; then
    echo "📦 Kopiere Workspace-Storage nach Cloud..."
    cp -r "$STORAGE_PATH"/* "$CLOUD_DIR/$WORKSPACE_ID/" 2>/dev/null || true
    echo "✅ Workspace-Storage kopiert"
else
    echo "⚠️  Workspace-Storage nicht gefunden: $STORAGE_PATH"
    echo "   Öffne den Workspace zuerst in Cursor, damit die Storage erstellt wird."
fi

# Symlinks erstellen
echo ""
echo "🔗 Erstelle Symlinks..."
mkdir -p "$HOME/Library/Application Support/Cursor/User/workspaceStorage"
ln -sf "$CLOUD_DIR/$WORKSPACE_ID" "$HOME/Library/Application Support/Cursor/User/workspaceStorage/$WORKSPACE_ID"
ln -sf "$CLOUD_DIR/$WORKSPACE_ID" "$HOME/Library/Application Support/Cursor/User/workspaceStorage/$CURRENT_HASH"
echo "✅ Symlinks erstellt"

echo ""
echo "✅ Setup abgeschlossen!"
echo ""
echo "📝 Nächste Schritte für weitere Rechner/Benutzer:"
echo "1. Stelle sicher, dass Cloud-Sync aktiviert ist"
echo "2. Führe auf jedem weiteren Rechner/Benutzer aus:"
echo "   ./setup-cursor-cloud-sync-remote.sh $WORKFLOW_ID $CLOUD_PROVIDER"
echo ""
echo "⚠️  WICHTIG: Cursor sollte nicht gleichzeitig von mehreren Benutzern geöffnet werden!"

