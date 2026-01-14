#!/bin/bash
# Setup-Script für Rechner 1 (kunkel)
# Führt alle notwendigen Schritte für das Setup auf Rechner 1 durch

set -e

echo "=========================================="
echo "Setup Rechner 1 (kunkel)"
echo "=========================================="
echo ""

# Prüfe, ob als Admin-Benutzer ausgeführt
if [ "$EUID" -ne 0 ] && ! groups | grep -q "admin"; then
    echo "⚠️  Warnung: Script sollte als Admin-Benutzer ausgeführt werden"
    echo "   Falls Berechtigungsfehler auftreten, als Admin-Benutzer ausführen"
    echo ""
fi

WORKSPACE_DIR="/Users/Shared/n8n-workflows"
REPO_URL="https://github.com/peerendees/n8n-workflows.git"

# Schritt 1: Git Repository klonen
echo "📥 Schritt 1: Git Repository klonen..."
if [ -d "$WORKSPACE_DIR" ]; then
    echo "⚠️  Verzeichnis existiert bereits: $WORKSPACE_DIR"
    echo "   Überspringe Klonen. Falls neu klonen gewünscht, Verzeichnis zuerst löschen."
    cd "$WORKSPACE_DIR"
else
    cd /Users/Shared
    git clone "$REPO_URL" n8n-workflows
    cd "$WORKSPACE_DIR"
    echo "✅ Repository geklont"
fi
echo ""

# Schritt 2: Berechtigungen setzen
echo "🔐 Schritt 2: Berechtigungen setzen..."
if [ -f "$WORKSPACE_DIR/docs/setup/fix-permissions.sh" ]; then
    chmod +x "$WORKSPACE_DIR/docs/setup/fix-permissions.sh"
    "$WORKSPACE_DIR/docs/setup/fix-permissions.sh"
    echo "✅ Berechtigungen gesetzt"
else
    echo "❌ Fehler: fix-permissions.sh nicht gefunden"
    exit 1
fi
echo ""

# Schritt 3: Symlink für kunkel erstellen
echo "🔗 Schritt 3: Symlink für kunkel erstellen..."
if [ -L "$HOME/n8n-workflows" ]; then
    echo "⚠️  Symlink existiert bereits: $HOME/n8n-workflows"
elif [ -d "$HOME/n8n-workflows" ]; then
    echo "⚠️  Verzeichnis existiert bereits (kein Symlink): $HOME/n8n-workflows"
    echo "   Bitte manuell prüfen und ggf. löschen"
else
    ln -s "$WORKSPACE_DIR" "$HOME/n8n-workflows"
    echo "✅ Symlink erstellt: $HOME/n8n-workflows → $WORKSPACE_DIR"
fi
echo ""

# Schritt 4: Prüfungen
echo "=========================================="
echo "Prüfungen"
echo "=========================================="
echo ""

echo "📁 Owner/Gruppe:"
ls -ld "$WORKSPACE_DIR" | awk '{print $3 " " $4}'
echo ""

echo "📁 Berechtigungen:"
stat -f "%Sp %N" "$WORKSPACE_DIR"
stat -f "%Sp %N" "$WORKSPACE_DIR/README.md"
echo ""

echo "🔗 Symlink:"
if [ -L "$HOME/n8n-workflows" ]; then
    ls -la "$HOME/n8n-workflows" | head -1
    echo "✅ Symlink funktioniert"
else
    echo "⚠️  Symlink nicht gefunden"
fi
echo ""

echo "📝 Git-Status:"
cd "$WORKSPACE_DIR"
git status --short
echo ""

echo "=========================================="
echo "✅ Setup abgeschlossen!"
echo "=========================================="
echo ""
echo "Nächste Schritte:"
echo "1. Cursor öffnen"
echo "2. File → Open Folder → $HOME/n8n-workflows"
echo "3. Workspace-Storage wird automatisch erstellt"
echo ""
echo "Prüfung:"
echo "  cd $HOME/n8n-workflows"
echo "  ./docs/setup/check-cursor-workspace.sh"
echo ""

