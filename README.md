# n8n Workflows Repository

Dieses Repository enthält n8n-Workflows für die Synchronisation zwischen GitHub und n8n.

## 📁 Struktur

- `n8n-Backup-Workflow.json` - Backup-Workflow (n8n → GitHub)
- `github-to-n8n-sync-workflow.json` - Synchronisations-Workflow (GitHub → n8n)
- `list-workflows-n8n.json` - Workflow zum Auflisten aller Workflows
- `list-workflows.sh` - Shell-Script zum Auflisten aller Workflows
- `n8n/` - Gesicherte Workflow-Dateien
- `workflows/` - Kategorisierte Workflows
- `docs/` - 📚 **Dokumentation** (siehe [docs/README.md](docs/README.md))

## 🚀 Cursor Multi-Computer Setup

Für mehrere Rechner mit mehreren Benutzern:

**⭐ Hauptanleitung:** [`docs/setup/SETUP-ANLEITUNG.md`](docs/setup/SETUP-ANLEITUNG.md)

**Schnellstart:**

1. **Erster Rechner:** Workspace nach `/Users/Shared/` verschieben
   ```bash
   ./docs/setup/move-to-shared.sh
   ```

2. **Weitere Rechner:** Git klonen und Setup
   ```bash
   git clone [repo-url] /Users/Shared/n8n-workflows
   cd /Users/Shared/n8n-workflows
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

**Weitere Dokumentation:**
- [`docs/setup/SETUP-ANLEITUNG.md`](docs/setup/SETUP-ANLEITUNG.md) - Komplette Schritt-für-Schritt Anleitung
- [`docs/setup/CURSOR-MULTI-COMPUTER-SETUP.md`](docs/setup/CURSOR-MULTI-COMPUTER-SETUP.md) - Gemeinsame Chat-Historie (optional)

## Setup

### 1. GitHub → n8n Synchronisation einrichten

1. **Workflow importieren:**
   - `github-to-n8n-sync-workflow.json` in n8n importieren
   - **WICHTIG:** n8n URI anpassen für Hostinger:
     - Es gibt in meinem Paket keine Umgebungsvariablen.
     - In n8n: Workflow öffnen → Environment Variables
     - Variable `N8N_URL` erstellen mit deiner Hostinger n8n URL (z.B. `https://deine-domain.hostinger.com`)
     - Oder direkt in den HTTP Request Nodes die URL ändern

2. **Webhook einrichten:**
   - Workflow aktivieren und Webhook-URL kopieren
   - GitHub Repository → Settings → Webhooks → Add webhook
   - Payload URL: Webhook-URL aus n8n
   - Content type: `application/json`
   - Events: Nur `push` auswählen
   - Webhook aktivieren

3. **Credentials prüfen:**
   - GitHub API Credentials müssen gesetzt sein
   - n8n API Credentials müssen gesetzt sein

### 2. Backup-Workflow verwenden

Der Backup-Workflow (`n8n-Backup-Workflow.json`) sichert automatisch alle n8n Workflows nach GitHub.

**Manueller Backup des Backup-Workflows selbst:**
- "Manual Trigger - Workflow Backup" im Backup-Workflow ausführen
- Speichert den Workflow selbst auf GitHub unter `n8n-Backup-Workflow.json`

## Workflow-IDs finden

### Option 1: n8n-Workflow verwenden
1. `list-workflows-n8n.json` in n8n importieren
2. Manuell ausführen
3. Erhält Liste aller Workflows mit IDs per Threema

### Option 2: Shell-Script verwenden
```bash
# n8n URL anpassen für Hostinger
N8N_URL="https://deine-n8n-instanz.hostinger.com" ./list-workflows.sh
```

## Neue Ordner-Struktur (geplant)

Zukünftig werden Workflows in folgender Struktur gespeichert:
```
n8n/
├── {Workflow-ID}/
│   └── {Workflow-Name}.json
```

Dies ermöglicht:
- Eindeutige Identifikation über Workflow-ID
- Lesbare Dateinamen
- Automatische Erkennung von Umbenennungen

## Entwicklungsworkflow

### Multi-Computer Workflow

**Wichtig:** Alle Git-Operationen erfolgen aus `/Users/Shared/n8n-workflows` (oder über Symlink)

**Auf Rechner 1 (Haupt-Rechner):**
```bash
cd /Users/Shared/n8n-workflows  # Oder: cd ~/n8n-workflows
# Arbeiten, Dateien ändern
git add .
git commit -m "Änderungsbeschreibung"
git push origin main
```

**Auf Rechner 2 (beim Wechseln):**
```bash
cd /Users/Shared/n8n-workflows
git pull origin main  # Holt alle Änderungen von GitHub
# Jetzt weiterarbeiten
```

### n8n Synchronisation

1. **In Cursor entwickeln:**
   - Workflow-Dateien bearbeiten
   - Änderungen committen und pushen

2. **Automatische Synchronisation:**
   - GitHub Webhook löst n8n-Workflow aus
   - Workflow wird automatisch in n8n aktualisiert

3. **Manuelle Synchronisation:**
   - Falls Webhook nicht funktioniert: Workflow manuell in n8n importieren

## Wichtige Hinweise

- **n8n URL:** Muss in allen Workflows auf deine Hostinger-Instanz zeigen
- **Credentials:** GitHub und n8n API Credentials müssen korrekt konfiguriert sein
- **Webhook:** Muss von GitHub aus erreichbar sein (öffentliche URL oder Tunnel)

## Docker Setup (optional)

Siehe vorhandene `docker-compose.yml` für lokale Entwicklung.
