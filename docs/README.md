# Dokumentation

Diese Dokumentation ist nach Themenbereichen organisiert.

## 📁 Verzeichnisstruktur

### `/docs/setup/` - Setup-Anleitungen
- **`SETUP-ANLEITUNG.md`** - ⭐ **HAUPTANLEITUNG** - Komplette Schritt-für-Schritt Anleitung für Multi-Computer Multi-User Setup
- `move-to-shared.sh` - Workspace nach `/Users/Shared/` verschieben (Schritt 1)
- `fix-permissions.sh` - Berechtigungen korrigieren
- `check-cursor-workspace.sh` - Cursor Workspace-Storage prüfen
- `CURSOR-MULTI-COMPUTER-SETUP.md` - Multi-Computer Chat-Historie Setup (optional)
- `setup-cursor-cloud-sync.sh` - Cloud-Sync für Chat-Historie (Schritt 5)
- `setup-cursor-cloud-sync-remote.sh` - Cloud-Sync für weitere Rechner
- `GITHUB-SYNC-ANLEITUNG.md` - GitHub ↔ n8n Synchronisation
- `SETUP-SCRIPTS.md` - Weitere Setup-Scripts
- `sudoers-macos-anleitung.md` - macOS sudoers Konfiguration

### `/docs/workflows/` - Workflow-Dokumentation
- `HEDY-*.md` - Hedy Workflow Dokumentation
- `WORKFLOW-*.md` - Allgemeine Workflow-Dokumentation
- `NODE-KOPIEREN.md` - Node-Kopieren Anleitung
- `COACHING-SESSION-ABLAUF.md` - Coaching-Workflow Ablauf

### `/docs/notion/` - Notion Integration
- `NOTION-*.md` - Notion API und Integration Dokumentation

### `/docs/debugging/` - Debugging & Troubleshooting
- `DEBUG-*.md` - Debugging-Anleitungen
- `WEBHOOK-*.md` - Webhook-Debugging
- `TOKEN-FINDEN.md` - Token-Management
- `HTTPIE-TEST-BODIES.md` - HTTPie Test-Daten
- `403-FORBIDDEN-LÖSUNG.md` - 403 Fehler-Lösung
- `HEADER-AUTH-LÖSUNG.md` - Header-Authentifizierung

## 🚀 Schnellstart

### Cursor Multi-Computer Setup

**Für neue Rechner/Benutzer:** Siehe **[SETUP-ANLEITUNG.md](setup/SETUP-ANLEITUNG.md)** für die komplette Schritt-für-Schritt Anleitung.

**Kurze Übersicht:**

1. **Erster Rechner:** Workspace nach `/Users/Shared/` verschieben
   ```bash
   ./docs/setup/move-to-shared.sh
   ```

2. **Weitere Rechner:** Git klonen und Berechtigungen setzen
   ```bash
   git clone [repo-url] /Users/Shared/n8n-workflows
   ./docs/setup/fix-permissions.sh
   ```

3. **Weitere Benutzer:** Symlink erstellen
   ```bash
   ln -s /Users/Shared/n8n-workflows ~/n8n-workflows
   ```

4. **Cursor Workspace prüfen:**
   ```bash
   ./docs/setup/check-cursor-workspace.sh
   ```

Siehe **[SETUP-ANLEITUNG.md](setup/SETUP-ANLEITUNG.md)** für Details und Troubleshooting.

## 📚 Weitere Dokumentation

- **Haupt-README:** Siehe `/README.md` im Root-Verzeichnis
- **Workflow-Struktur:** Siehe `/README.md` → "Neue Ordner-Struktur"

