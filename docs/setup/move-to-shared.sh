#!/bin/bash
# Script zum Verschieben des Workspace nach /Users/Shared/
# Schritt 1: Workspace verschieben, Symlink erstellen, Berechtigungen setzen

set -e

SOURCE_DIR="/Users/hpcn/n8n-workflows"
TARGET_DIR="/Users/Shared/n8n-workflows"
BACKUP_DIR="/Users/Shared/n8n-workflows.backup.$(date +%Y%m%d_%H%M%S)"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Workspace nach /Users/Shared/ verschieben"
echo "=========================================="
echo ""

# Prüfungen
echo "🔍 Prüfe Voraussetzungen..."

# Prüfe ob Source existiert
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Fehler: Source-Verzeichnis nicht gefunden: $SOURCE_DIR${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Source-Verzeichnis gefunden: $SOURCE_DIR${NC}"

# Prüfe ob bereits ein Symlink existiert
if [ -L "$SOURCE_DIR" ]; then
    echo -e "${YELLOW}⚠️  Warnung: $SOURCE_DIR ist bereits ein Symlink!${NC}"
    echo "   Ziel: $(readlink "$SOURCE_DIR")"
    read -p "   Fortfahren? (j/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
        echo "Abgebrochen."
        exit 1
    fi
fi

# Prüfe ob Target bereits existiert
if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}⚠️  Warnung: Target-Verzeichnis existiert bereits: $TARGET_DIR${NC}"
    read -p "   Backup erstellen und überschreiben? (j/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[JjYy]$ ]]; then
        echo "📦 Erstelle Backup..."
        sudo mv "$TARGET_DIR" "$BACKUP_DIR"
        echo -e "${GREEN}✅ Backup erstellt: $BACKUP_DIR${NC}"
    else
        echo "Abgebrochen."
        exit 1
    fi
fi

# Prüfe ob /Users/Shared existiert
if [ ! -d "/Users/Shared" ]; then
    echo -e "${RED}❌ Fehler: /Users/Shared existiert nicht!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ /Users/Shared existiert${NC}"

# Prüfe Git-Status
cd "$SOURCE_DIR"
if [ -d ".git" ]; then
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Warnung: Es gibt uncommittete Änderungen im Git-Repository!${NC}"
        read -p "   Trotzdem fortfahren? (j/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
            echo "Abgebrochen. Bitte zuerst committen oder stashen."
            exit 1
        fi
    fi
    echo -e "${GREEN}✅ Git-Repository gefunden, Status OK${NC}"
fi

echo ""
echo "📋 Zusammenfassung:"
echo "   Source: $SOURCE_DIR"
echo "   Target: $TARGET_DIR"
echo ""

read -p "🚀 Fortfahren mit Verschiebung? (j/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
    echo "Abgebrochen."
    exit 1
fi

echo ""
echo "📦 Schritt 1: Verschiebe Workspace..."
sudo mv "$SOURCE_DIR" "$TARGET_DIR"
echo -e "${GREEN}✅ Workspace verschoben${NC}"

echo ""
echo "🔗 Schritt 2: Erstelle Symlink..."
ln -s "$TARGET_DIR" "$SOURCE_DIR"
echo -e "${GREEN}✅ Symlink erstellt: $SOURCE_DIR -> $TARGET_DIR${NC}"

echo ""
echo "🔐 Schritt 3: Setze Berechtigungen..."
# Owner und Gruppe setzen
sudo chown -R hpcn:staff "$TARGET_DIR"
echo -e "${GREEN}✅ Owner/Gruppe gesetzt${NC}"

# Verzeichnisse: 775 (rwxrwxr-x)
find "$TARGET_DIR" -type d -exec sudo chmod 775 {} \;
echo -e "${GREEN}✅ Verzeichnis-Berechtigungen gesetzt (775)${NC}"

# Dateien: 664 (rw-rw-r--)
find "$TARGET_DIR" -type f -exec sudo chmod 664 {} \;
echo -e "${GREEN}✅ Datei-Berechtigungen gesetzt (664)${NC}"

# Scripts ausführbar machen: 775
find "$TARGET_DIR" -type f \( -name "*.sh" -o -name "*.py" \) -exec sudo chmod 775 {} \;
echo -e "${GREEN}✅ Script-Berechtigungen gesetzt (775)${NC}"

# .git Verzeichnis: 775
if [ -d "$TARGET_DIR/.git" ]; then
    sudo chmod -R 775 "$TARGET_DIR/.git"
    echo -e "${GREEN}✅ Git-Verzeichnis-Berechtigungen gesetzt${NC}"
fi

echo ""
echo "🧹 Schritt 4: Aufräumen..."
# Entferne Backup-Verzeichnis falls leer oder sehr alt (optional)
# Für jetzt: Backup behalten für Sicherheit

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Setup abgeschlossen!${NC}"
echo "=========================================="
echo ""
echo "📁 Workspace: $TARGET_DIR"
echo "🔗 Symlink: $SOURCE_DIR -> $TARGET_DIR"
echo ""
echo "📝 Nächste Schritte:"
echo "1. Prüfe ob alles funktioniert:"
echo "   cd $SOURCE_DIR"
echo "   ls -la"
echo ""
echo "2. Für weitere Benutzer auf diesem Rechner:"
echo "   ln -s $TARGET_DIR ~/n8n-workflows"
echo ""
echo "3. Für Cursor-Chat-Setup siehe:"
echo "   docs/setup/CURSOR-MULTI-COMPUTER-SETUP.md"
echo ""

