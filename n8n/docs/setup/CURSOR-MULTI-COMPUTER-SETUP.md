# Multi-Computer Multi-User Setup für Cursor Workspaces

## Szenario

- **Mehrere Rechner** (verschiedene Macs)
- **Mehrere Benutzerprofile pro Rechner** (nie gleichzeitig aktiv)
- **Unterschiedliche Verzeichnisse pro Rechner/Benutzer** (z.B. `/Users/hpcn/n8n-workflows` auf Rechner 1, `/Users/kunkel/n8n-workflows` auf Rechner 2)
- **Gleiche Chat-Historie** trotz unterschiedlicher Pfade
- **Workflow-ID als Ordnername** für n8n-Synchronisation
- **Skalierbar** - neue Rechner/Benutzer einfach hinzufügbar

## Herausforderung

Cursor verwendet den **absoluten Pfad** als Hash für die Workspace-Storage:
- `/Users/hpcn/n8n-workflows` → Hash A
- `/Users/kunkel/n8n-workflows` → Hash B (unterschiedlich!)

**Problem:** Unterschiedliche Hashes = keine gemeinsamen Chats

## Lösung: Cloud-Sync für Cursor Workspace-Storage

### Konzept

1. **Git für Dateien** - bereits vorhanden ✅
2. **Cloud-Sync für Chat-Historie** - iCloud Drive, Dropbox, oder OneDrive
3. **Einheitlicher Workspace-Identifier** - basierend auf Workflow-ID statt Pfad

---

## Setup-Anleitung

### Schritt 1: Cloud-Sync-Verzeichnis einrichten

**Auf dem ersten Rechner (z.B. Rechner 1, Benutzer hpcn):**

1. **Cloud-Sync-Verzeichnis erstellen:**
   - **iCloud Drive:** `~/Library/Mobile Documents/com~apple~CloudDocs/Cursor-Workspaces`
   - **Dropbox:** `~/Dropbox/Cursor-Workspaces`
   - **OneDrive:** `~/OneDrive/Cursor-Workspaces`

   Beispiel mit iCloud Drive:
```bash
mkdir -p ~/Library/Mobile\ Documents/com~apple~CloudDocs/Cursor-Workspaces
```

2. **Workspace-Hash basierend auf Workflow-ID berechnen:**

   Da jeder Workspace eine Workflow-ID hat, verwenden wir diese als Identifier:
```bash
# Für den Haupt-Workspace (n8n-workflows)
WORKFLOW_ID="n8n-workflows-main"  # Oder die tatsächliche n8n Workflow-ID
WORKSPACE_ID=$(echo -n "$WORKFLOW_ID" | shasum -a 256 | cut -d' ' -f1)
echo "Workspace-ID: $WORKSPACE_ID"
```

3. **Workspace-Storage in Cloud-Sync verschieben:**
```bash
# Aktuellen Workspace-Hash ermitteln
CURRENT_PATH="/Users/hpcn/n8n-workflows"
CURRENT_HASH=$(python3 -c "import hashlib; print(hashlib.sha256(b'$CURRENT_PATH').hexdigest())")

# Cloud-Verzeichnis erstellen
CLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Cursor-Workspaces"
mkdir -p "$CLOUD_DIR/$WORKSPACE_ID"

# Workspace-Storage verschieben
mv ~/Library/Application\ Support/Cursor/User/workspaceStorage/$CURRENT_HASH/* "$CLOUD_DIR/$WORKSPACE_ID/" 2>/dev/null || true

# Oder kopieren, falls bereits existiert:
cp -r ~/Library/Application\ Support/Cursor/User/workspaceStorage/$CURRENT_HASH/* "$CLOUD_DIR/$WORKSPACE_ID/" 2>/dev/null || true
```

4. **Symlink erstellen:**
```bash
# Alten Workspace-Storage löschen (falls leer)
rmdir ~/Library/Application\ Support/Cursor/User/workspaceStorage/$CURRENT_HASH 2>/dev/null || true

# Symlink auf Cloud-Verzeichnis erstellen
ln -s "$CLOUD_DIR/$WORKSPACE_ID" ~/Library/Application\ Support/Cursor/User/workspaceStorage/$WORKSPACE_ID
```

### Schritt 2: Auf weiteren Rechnern/Benutzern einrichten

**Auf jedem weiteren Rechner/Benutzer:**

1. **Cloud-Sync-Verzeichnis prüfen:**
```bash
CLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Cursor-Workspaces"
# Oder für Dropbox:
# CLOUD_DIR="$HOME/Dropbox/Cursor-Workspaces"
```

2. **Workspace-ID berechnen (muss identisch sein!):**
```bash
WORKFLOW_ID="n8n-workflows-main"  # GLEICHE ID wie auf Rechner 1!
WORKSPACE_ID=$(echo -n "$WORKFLOW_ID" | shasum -a 256 | cut -d' ' -f1)
echo "Workspace-ID: $WORKSPACE_ID"
```

3. **Symlink erstellen:**
```bash
# Lokalen Workspace-Pfad ermitteln
LOCAL_WORKSPACE_PATH="$HOME/n8n-workflows"  # Oder wo auch immer der Workspace liegt
LOCAL_HASH=$(python3 -c "import hashlib; print(hashlib.sha256(b'$LOCAL_WORKSPACE_PATH').hexdigest())")

# Cloud-Verzeichnis sollte bereits existieren (durch Sync)
# Symlink erstellen
mkdir -p ~/Library/Application\ Support/Cursor/User/workspaceStorage/
ln -s "$CLOUD_DIR/$WORKSPACE_ID" ~/Library/Application\ Support/Cursor/User/workspaceStorage/$WORKSPACE_ID

# Optional: Auch für den lokalen Hash-Pfad (falls Cursor diesen verwendet)
ln -s "$CLOUD_DIR/$WORKSPACE_ID" ~/Library/Application\ Support/Cursor/User/workspaceStorage/$LOCAL_HASH
```

### Schritt 3: Workspace-Verzeichnis einrichten

**Auf jedem Rechner/Benutzer:**

1. **Git Repository klonen/verlinken:**
```bash
# Option A: Git Clone (empfohlen für verschiedene Rechner)
cd ~
git clone <dein-github-repo-url> n8n-workflows

# Option B: Symlink (nur wenn auf gleichem Rechner)
ln -s /Users/hpcn/n8n-workflows ~/n8n-workflows
```

2. **Workspace in Cursor öffnen:**
   - Cursor öffnen
   - File → Open Folder → `~/n8n-workflows` auswählen
   - Cursor erstellt automatisch die Workspace-Storage

3. **Symlink auf Cloud-Storage prüfen:**
```bash
ls -la ~/Library/Application\ Support/Cursor/User/workspaceStorage/ | grep "$WORKSPACE_ID"
```

---

## Automatisierung: Setup-Script

### Script für ersten Rechner/Benutzer

**Datei:** `docs/setup/setup-cursor-cloud-sync.sh`

```bash
#!/bin/bash
# setup-cursor-cloud-sync.sh

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
    echo "Unbekannter Cloud-Provider: $CLOUD_PROVIDER"
    exit 1
    ;;
esac

# Workspace-ID berechnen
WORKSPACE_ID=$(echo -n "$WORKFLOW_ID" | shasum -a 256 | cut -d' ' -f1)
echo "Workflow-ID: $WORKFLOW_ID"
echo "Workspace-ID: $WORKSPACE_ID"
echo "Cloud-Verzeichnis: $CLOUD_DIR"

# Aktuellen Workspace-Pfad ermitteln
CURRENT_WORKSPACE_PATH=$(pwd)
CURRENT_HASH=$(python3 -c "import hashlib; print(hashlib.sha256(b'$CURRENT_WORKSPACE_PATH').hexdigest())")
echo "Aktueller Workspace-Pfad: $CURRENT_WORKSPACE_PATH"
echo "Aktueller Hash: $CURRENT_HASH"

# Cloud-Verzeichnis erstellen
mkdir -p "$CLOUD_DIR/$WORKSPACE_ID"

# Workspace-Storage verschieben/kopieren
STORAGE_PATH="$HOME/Library/Application Support/Cursor/User/workspaceStorage/$CURRENT_HASH"
if [ -d "$STORAGE_PATH" ]; then
    echo "Verschiebe Workspace-Storage..."
    cp -r "$STORAGE_PATH"/* "$CLOUD_DIR/$WORKSPACE_ID/" 2>/dev/null || true
fi

# Symlinks erstellen
mkdir -p "$HOME/Library/Application Support/Cursor/User/workspaceStorage"
ln -sf "$CLOUD_DIR/$WORKSPACE_ID" "$HOME/Library/Application Support/Cursor/User/workspaceStorage/$WORKSPACE_ID"
ln -sf "$CLOUD_DIR/$WORKSPACE_ID" "$HOME/Library/Application Support/Cursor/User/workspaceStorage/$CURRENT_HASH"

echo ""
echo "✅ Setup abgeschlossen!"
echo ""
echo "Für weitere Rechner/Benutzer:"
echo "1. Cloud-Sync-Verzeichnis sollte automatisch synchronisiert werden"
echo "2. Führe das Setup-Script für weitere Benutzer aus:"
echo "   ./docs/setup/setup-cursor-cloud-sync-remote.sh [WORKFLOW_ID] [CLOUD_PROVIDER] [LOCAL_PATH]"
```

### Script für weitere Rechner/Benutzer

**Datei:** `docs/setup/setup-cursor-cloud-sync-remote.sh`

```bash
#!/bin/bash
# setup-cursor-cloud-sync-remote.sh

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
    echo "Unbekannter Cloud-Provider: $CLOUD_PROVIDER"
    exit 1
    ;;
esac

# Workspace-ID berechnen (muss identisch sein!)
WORKSPACE_ID=$(echo -n "$WORKFLOW_ID" | shasum -a 256 | cut -d' ' -f1)
LOCAL_HASH=$(python3 -c "import hashlib; print(hashlib.sha256(b'$LOCAL_WORKSPACE_PATH').hexdigest())")

echo "Workflow-ID: $WORKFLOW_ID"
echo "Workspace-ID: $WORKSPACE_ID"
echo "Lokaler Workspace-Pfad: $LOCAL_WORKSPACE_PATH"
echo "Lokaler Hash: $LOCAL_HASH"

# Prüfen ob Cloud-Verzeichnis existiert
if [ ! -d "$CLOUD_DIR/$WORKSPACE_ID" ]; then
    echo "⚠️  Cloud-Verzeichnis nicht gefunden: $CLOUD_DIR/$WORKSPACE_ID"
    echo "Stelle sicher, dass Cloud-Sync aktiviert ist und der erste Rechner bereits eingerichtet wurde."
    exit 1
fi

# Symlinks erstellen
mkdir -p "$HOME/Library/Application Support/Cursor/User/workspaceStorage"
ln -sf "$CLOUD_DIR/$WORKSPACE_ID" "$HOME/Library/Application Support/Cursor/User/workspaceStorage/$WORKSPACE_ID"
ln -sf "$CLOUD_DIR/$WORKSPACE_ID" "$HOME/Library/Application Support/Cursor/User/workspaceStorage/$LOCAL_HASH"

echo ""
echo "✅ Setup abgeschlossen!"
echo "Öffne den Workspace in Cursor: $LOCAL_WORKSPACE_PATH"
```

---

## Workflow-ID basierte Struktur

### Empfohlene Struktur

Für jeden Workflow einen eigenen Workspace mit eigener Chat-Historie:

```
~/Cursor-Workspaces/
├── {workflow-id-1}/
│   └── [Cursor Workspace-Storage]
├── {workflow-id-2}/
│   └── [Cursor Workspace-Storage]
└── n8n-workflows-main/
    └── [Cursor Workspace-Storage für Haupt-Workspace]
```

### Workflow-ID ermitteln

```bash
# Aus n8n Workflow JSON:
WORKFLOW_ID=$(cat workflow.json | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")

# Oder manuell aus n8n UI kopieren
```

---

## Vorteile dieser Lösung

✅ **Unterschiedliche Verzeichnisse** - Jeder Rechner/Benutzer kann eigenen Pfad haben  
✅ **Gleiche Chats** - Cloud-Sync sorgt für Synchronisation  
✅ **Skalierbar** - Neue Rechner/Benutzer einfach hinzufügbar  
✅ **Workflow-ID basiert** - Passt zu deiner n8n-Struktur  
✅ **Keine gleichzeitige Nutzung nötig** - Cloud-Sync übernimmt Synchronisation  

## Wichtige Hinweise

⚠️ **Cloud-Sync muss aktiviert sein** - iCloud Drive, Dropbox oder OneDrive  
⚠️ **Nicht gleichzeitig öffnen** - Cursor sollte nicht gleichzeitig von mehreren Benutzern geöffnet werden (kann zu Konflikten führen)  
⚠️ **Erster Setup** - Erster Rechner/Benutzer muss Workspace-Storage erstellen  
⚠️ **Workflow-ID konsistent** - Muss auf allen Rechnern/Benutzern identisch sein  

---

## Troubleshooting

### Cloud-Verzeichnis wird nicht synchronisiert

```bash
# Prüfen ob Cloud-Sync aktiv ist
ls -la "$HOME/Library/Mobile Documents/com~apple~CloudDocs/"

# Manuell synchronisieren (iCloud)
# System Settings → Apple ID → iCloud → iCloud Drive → Options → Desktop & Documents Folders
```

### Symlink funktioniert nicht

```bash
# Prüfen ob Symlink existiert
ls -la ~/Library/Application\ Support/Cursor/User/workspaceStorage/ | grep "$WORKSPACE_ID"

# Symlink neu erstellen
rm ~/Library/Application\ Support/Cursor/User/workspaceStorage/$WORKSPACE_ID
ln -s "$CLOUD_DIR/$WORKSPACE_ID" ~/Library/Application\ Support/Cursor/User/workspaceStorage/$WORKSPACE_ID
```

### Chats werden nicht geteilt

1. Prüfe ob Workflow-ID identisch ist auf allen Rechnern
2. Prüfe ob Cloud-Verzeichnis synchronisiert wurde
3. Prüfe ob Symlink korrekt erstellt wurde
4. Starte Cursor neu

