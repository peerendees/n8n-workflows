#!/bin/bash
# Script zum Verschieben des Workspace nach /Users/Shared/
# Schritt 1: Workspace verschieben, Symlink erstellen, Berechtigungen setzen
# Unterstützt Resume/Neustart bei Abbruch

set -e

# Automatische Pfad-Erkennung: Workspace-Verzeichnis ist dort, wo das Script liegt
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Prüfe verschiedene mögliche Source-Pfade
POSSIBLE_SOURCES=(
    "$WORKSPACE_ROOT"
    "/Users/hpcn/n8n-workflows"
    "/Users/$(whoami)/n8n-workflows"
)

SOURCE_DIR=""
for possible_source in "${POSSIBLE_SOURCES[@]}"; do
    if [ -d "$possible_source" ] && [ -f "$possible_source/.git/config" ] 2>/dev/null; then
        SOURCE_DIR="$possible_source"
        break
    fi
done

# Falls nicht gefunden, verwende Workspace-Root
if [ -z "$SOURCE_DIR" ]; then
    SOURCE_DIR="$WORKSPACE_ROOT"
fi

TARGET_DIR="/Users/Shared/n8n-workflows"
BACKUP_DIR="/Users/Shared/n8n-workflows.backup.$(date +%Y%m%d_%H%M%S)"
STATE_FILE="/tmp/move-to-shared-state.txt"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktion: State speichern
save_state() {
    echo "$1" > "$STATE_FILE"
}

# Funktion: State laden
load_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "start"
    fi
}

# Funktion: State löschen
clear_state() {
    rm -f "$STATE_FILE"
}

echo "=========================================="
echo "Workspace nach /Users/Shared/ verschieben"
echo "=========================================="
echo ""

# Prüfe ob bereits verschoben wurde
CURRENT_STATE=$(load_state)
if [ -d "$TARGET_DIR" ] && [ -L "$SOURCE_DIR" ] && [ "$(readlink "$SOURCE_DIR")" = "$TARGET_DIR" ]; then
    echo -e "${GREEN}✅ Workspace wurde bereits nach /Users/Shared/ verschoben!${NC}"
    echo ""
    echo "📁 Workspace: $TARGET_DIR"
    echo "🔗 Symlink: $SOURCE_DIR -> $TARGET_DIR"
    echo ""
    read -p "🔄 Setup erneut durchführen? (j/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
        echo "Abgebrochen."
        exit 0
    fi
    clear_state
    CURRENT_STATE="start"
fi

# Resume-Funktionalität
if [ "$CURRENT_STATE" != "start" ] && [ "$CURRENT_STATE" != "" ]; then
    echo -e "${BLUE}🔄 Resume-Modus: Vorheriger Zustand gefunden${NC}"
    echo "   Letzter Schritt: $CURRENT_STATE"
    echo ""
    read -p "   Mit diesem Schritt fortfahren? (j/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
        clear_state
        CURRENT_STATE="start"
    fi
fi

# Prüfungen
echo "🔍 Prüfe Voraussetzungen..."

# Prüfe ob aktueller Benutzer Admin-Rechte hat
CURRENT_USER=$(whoami)
IS_ADMIN=false

# Prüfe ob Benutzer in admin-Gruppe ist
if groups | grep -q "admin"; then
    IS_ADMIN=true
elif dscl . -read /Groups/admin GroupMembership 2>/dev/null | grep -q "$CURRENT_USER"; then
    IS_ADMIN=true
fi

if [ "$IS_ADMIN" = false ] && [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Fehler: Aktueller Benutzer '$CURRENT_USER' hat keine Admin-Rechte!${NC}"
    echo ""
    echo "Dieses Script benötigt Admin-Rechte für:"
    echo "  - Verschieben von Dateien nach /Users/Shared/"
    echo "  - Setzen von Berechtigungen"
    echo ""
    echo "🔧 Lösung: Führe das Script als Admin-Benutzer aus:"
    echo ""
    
    # Versuche Admin-Benutzer zu finden
    ADMIN_USERS=$(dscl . -read /Groups/admin GroupMembership 2>/dev/null | tr ' ' '\n' | grep -v "^GroupMembership:" | grep -v "^$" | grep -v "^root$")
    
    if [ -n "$ADMIN_USERS" ]; then
        echo "   Verfügbare Admin-Benutzer:"
        echo "$ADMIN_USERS" | while read admin_user; do
            echo "   - $admin_user"
        done
        echo ""
        FIRST_ADMIN=$(echo "$ADMIN_USERS" | head -1)
        echo "   Bitte direkt als '$FIRST_ADMIN' anmelden (nicht über sudo!)"
        echo "   Dann: cd $SOURCE_DIR && ./docs/setup/move-to-shared.sh"
    fi
    
    echo ""
    exit 1
fi
echo -e "${GREEN}✅ Admin-Rechte bestätigt (Benutzer: $CURRENT_USER)${NC}"

# Prüfe ob Source existiert
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Fehler: Source-Verzeichnis nicht gefunden: $SOURCE_DIR${NC}"
    echo ""
    echo "Mögliche Ursachen:"
    echo "  1. Workspace wurde bereits verschoben"
    echo "  2. Falscher Pfad"
    echo ""
    echo "Prüfe:"
    echo "  ls -la /Users/Shared/n8n-workflows"
    echo "  ls -la /Users/hpcn/n8n-workflows"
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
if [ -d "$TARGET_DIR" ] && [ "$SOURCE_DIR" != "$TARGET_DIR" ]; then
    echo -e "${YELLOW}⚠️  Warnung: Target-Verzeichnis existiert bereits: $TARGET_DIR${NC}"
    read -p "   Backup erstellen und überschreiben? (j/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[JjYy]$ ]]; then
        echo "📦 Erstelle Backup..."
        save_state "backup_created"
        if [ "$EUID" -eq 0 ]; then
            mv "$TARGET_DIR" "$BACKUP_DIR"
        elif [ "$IS_ADMIN" = true ]; then
            if mv "$TARGET_DIR" "$BACKUP_DIR" 2>/dev/null; then
                echo -e "${GREEN}✅ Backup erstellt (ohne sudo)${NC}"
            else
                mv "$TARGET_DIR" "$BACKUP_DIR" || sudo mv "$TARGET_DIR" "$BACKUP_DIR"
            fi
        else
            sudo mv "$TARGET_DIR" "$BACKUP_DIR"
        fi
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

# Prüfe Git-Status (nur wenn nicht bereits verschoben)
if [ "$SOURCE_DIR" != "$TARGET_DIR" ] && [ -d "$SOURCE_DIR/.git" ]; then
    if ! git -C "$SOURCE_DIR" diff-index --quiet HEAD -- 2>/dev/null; then
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

# Resume: Überspringe bereits durchgeführte Schritte
if [ "$CURRENT_STATE" = "moved" ]; then
    echo -e "${BLUE}⏭️  Überspringe Verschiebung (bereits durchgeführt)${NC}"
elif [ "$CURRENT_STATE" = "linked" ]; then
    echo -e "${BLUE}⏭️  Überspringe Verschiebung und Symlink (bereits durchgeführt)${NC}"
elif [ "$CURRENT_STATE" = "permissions_set" ]; then
    echo -e "${BLUE}⏭️  Überspringe Verschiebung, Symlink und Berechtigungen (bereits durchgeführt)${NC}"
else
    read -p "🚀 Fortfahren mit Verschiebung? (j/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
        echo "Abgebrochen."
        exit 1
    fi
fi

# Schritt 1: Verschiebung
if [ "$CURRENT_STATE" != "moved" ] && [ "$CURRENT_STATE" != "linked" ] && [ "$CURRENT_STATE" != "permissions_set" ]; then
    echo ""
    echo "📦 Schritt 1: Verschiebe Workspace..."
    save_state "moving"
    
    if [ "$SOURCE_DIR" = "$TARGET_DIR" ]; then
        echo -e "${GREEN}✅ Workspace bereits am Zielort${NC}"
    else
        if [ "$EUID" -eq 0 ]; then
            mv "$SOURCE_DIR" "$TARGET_DIR"
        elif [ "$IS_ADMIN" = true ]; then
            # Als Admin: versuche erst ohne sudo
            if mv "$SOURCE_DIR" "$TARGET_DIR" 2>/dev/null; then
                echo -e "${GREEN}✅ Workspace verschoben (ohne sudo)${NC}"
            else
                # Falls ohne sudo nicht möglich, mit mv versuchen (als Admin sollte es gehen)
                mv "$SOURCE_DIR" "$TARGET_DIR"
            fi
        else
            sudo mv "$SOURCE_DIR" "$TARGET_DIR"
        fi
        echo -e "${GREEN}✅ Workspace verschoben${NC}"
    fi
    save_state "moved"
fi

# Schritt 2: Symlink
if [ "$CURRENT_STATE" != "linked" ] && [ "$CURRENT_STATE" != "permissions_set" ]; then
    echo ""
    echo "🔗 Schritt 2: Erstelle Symlink..."
    save_state "linking"
    
    # Ermittle ursprünglichen Source-Pfad für Symlink
    ORIGINAL_SOURCE="/Users/hpcn/n8n-workflows"
    if [ ! -L "$ORIGINAL_SOURCE" ]; then
        ln -s "$TARGET_DIR" "$ORIGINAL_SOURCE"
        echo -e "${GREEN}✅ Symlink erstellt: $ORIGINAL_SOURCE -> $TARGET_DIR${NC}"
    else
        echo -e "${GREEN}✅ Symlink existiert bereits${NC}"
    fi
    save_state "linked"
fi

# Schritt 3: Berechtigungen
if [ "$CURRENT_STATE" != "permissions_set" ]; then
    echo ""
    echo "🔐 Schritt 3: Setze Berechtigungen..."
    save_state "setting_permissions"
    
    # Funktion für chown/chmod mit oder ohne sudo
    # WICHTIG: /Users/Shared/ gehört root, daher ist sudo immer nötig (auch für Admins)
    run_with_sudo_if_needed() {
        local cmd="$1"
        if [ "$EUID" -eq 0 ]; then
            # Als root: kein sudo nötig
            eval "$cmd"
        else
            # Für alle anderen (auch Admins): sudo verwenden
            # /Users/Shared/ gehört root, daher ist sudo erforderlich
            eval "sudo $cmd"
        fi
    }
    
    # Owner und Gruppe setzen
    run_with_sudo_if_needed "chown -R hpcn:staff \"$TARGET_DIR\""
    echo -e "${GREEN}✅ Owner/Gruppe gesetzt${NC}"
    
    # Verzeichnisse: 775 (rwxrwxr-x)
    run_with_sudo_if_needed "find \"$TARGET_DIR\" -type d -exec chmod 775 {} \\;"
    echo -e "${GREEN}✅ Verzeichnis-Berechtigungen gesetzt (775)${NC}"
    
    # Dateien: 664 (rw-rw-r--)
    run_with_sudo_if_needed "find \"$TARGET_DIR\" -type f -exec chmod 664 {} \\;"
    echo -e "${GREEN}✅ Datei-Berechtigungen gesetzt (664)${NC}"
    
    # Scripts ausführbar machen: 775
    run_with_sudo_if_needed "find \"$TARGET_DIR\" -type f \\( -name \"*.sh\" -o -name \"*.py\" \\) -exec chmod 775 {} \\;"
    echo -e "${GREEN}✅ Script-Berechtigungen gesetzt (775)${NC}"
    
    # .git Verzeichnis: 775
    if [ -d "$TARGET_DIR/.git" ]; then
        run_with_sudo_if_needed "chmod -R 775 \"$TARGET_DIR/.git\""
        echo -e "${GREEN}✅ Git-Verzeichnis-Berechtigungen gesetzt${NC}"
    fi
    
    save_state "permissions_set"
fi

# Aufräumen
echo ""
echo "🧹 Schritt 4: Aufräumen..."
clear_state
echo -e "${GREEN}✅ State-Datei gelöscht${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Setup abgeschlossen!${NC}"
echo "=========================================="
echo ""
echo "📁 Workspace: $TARGET_DIR"
echo "🔗 Symlink: $ORIGINAL_SOURCE -> $TARGET_DIR"
echo ""
echo "📝 Nächste Schritte:"
echo "1. Prüfe ob alles funktioniert:"
echo "   cd $ORIGINAL_SOURCE"
echo "   ls -la"
echo ""
echo "2. Für weitere Benutzer auf diesem Rechner:"
echo "   ln -s $TARGET_DIR ~/n8n-workflows"
echo ""
echo "3. Für Cursor-Chat-Setup siehe:"
echo "   docs/setup/CURSOR-MULTI-COMPUTER-SETUP.md"
echo ""
