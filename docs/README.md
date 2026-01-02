# Dokumentation

Diese Dokumentation ist nach Themenbereichen organisiert.

## 📁 Verzeichnisstruktur

### `/docs/setup/` - Setup-Anleitungen
- **`CURSOR-MULTI-COMPUTER-SETUP.md`** - ⭐ **HAUPTANLEITUNG** für Multi-Computer Multi-User Setup mit Cloud-Sync
- `setup-cursor-cloud-sync.sh` - Setup-Script für ersten Rechner/Benutzer
- `setup-cursor-cloud-sync-remote.sh` - Setup-Script für weitere Rechner/Benutzer
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

Für mehrere Rechner mit mehreren Benutzern:

1. **Erster Rechner/Benutzer:**
```bash
cd /path/to/n8n-workflows
./docs/setup/setup-cursor-cloud-sync.sh [WORKFLOW_ID] [CLOUD_PROVIDER]
```

2. **Weitere Rechner/Benutzer:**
```bash
cd /path/to/n8n-workflows
./docs/setup/setup-cursor-cloud-sync-remote.sh [WORKFLOW_ID] [CLOUD_PROVIDER] [LOCAL_PATH]
```

Siehe **[CURSOR-MULTI-COMPUTER-SETUP.md](setup/CURSOR-MULTI-COMPUTER-SETUP.md)** für Details.

## 📚 Weitere Dokumentation

- **Haupt-README:** Siehe `/README.md` im Root-Verzeichnis
- **Workflow-Struktur:** Siehe `/README.md` → "Neue Ordner-Struktur"

