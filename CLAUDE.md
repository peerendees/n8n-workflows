# CLAUDE.md

## Projektbeschreibung

n8n-Workflow-Automatisierung fuer Coaching, Kommunikation und Content-Erstellung. Die n8n-Instanz laeuft auf Hostinger (Self-Hosted) und wird bidirektional mit diesem GitHub-Repository synchronisiert. Eingesetzt von einem Solo-Entwickler fuer Geschaeftsprozesse rund um Threema-Messaging, fonio-Transkription, YouTube/Notion-Integration und KI-Agenten.

## Technologie-Stack

- **Automatisierung:** n8n (Self-Hosted auf Hostinger, v2.11.3)
- **Deployment:** Docker Compose (stable + beta), SQLite lokal
- **Versionierung:** Git/GitHub mit bidirektionalem Sync (n8n <-> GitHub)
- **Messaging:** Threema Work Gateway API
- **Datenbank:** PostgreSQL (DSGVO-konform, init.sql), SQLite (n8n lokal)
- **Scripts:** Bash (Backup, Workflow-Management, Setup)
- **Sprache:** Dokumentation und Commit-Messages auf Deutsch

## Dateistruktur

```
n8n/                        36 Live-Workflows (Auto-Backup von n8n)
  {workflowId}/               Ordner pro Workflow-ID
    {Workflow-Name}.json       JSON-Export mit id, name, nodes, connections
workflows/                  Workflow-Vorlagen nach Kategorie
  ai-agents/                  KI-Agenten, E-Mail, Content
  communication/              Threema, Gmail
  fieck/                      Fieckscher Feger Projekt
  fonio/                      Transkriptions-Workflows
  analysis/, business/, content-automation/, linkedIn-scraper/
docs/                       Dokumentation (Deutsch)
  setup/                      Multi-Computer Setup + Scripts
  debugging/                  Webhook/Auth Troubleshooting
  notion/                     Notion-Integration
  workflows/                  Workflow-spezifische Doku
docker-compose.yml          Stable n8n (Port 5678)
docker-compose.beta.yml     Beta n8n (Port 5679)
init.sql                    PostgreSQL-Schema (Threema, DSGVO)
*.sh                        Bash-Scripts (Backup, Workflow-Liste, Export)
BEST_PRACTICES.md           Sync-Architektur und Race-Condition-Vermeidung
config                      n8n Encryption Key — NICHT aendern/exponieren
```

### Wichtige Regeln

- `n8n/` wird automatisch vom Backup-Workflow verwaltet — nicht manuell aendern
- `config` enthaelt den n8n Encryption Key — niemals committen oder exponieren
- `.env`-Dateien und Credentials sind gitignored
- GitHub ist Master fuer Workflow-Logik, n8n ist Master fuer Laufzeit/Trigger
- Commit-Messages auf Deutsch, Auto-Backups mit Prefix `🤖 Auto-Backup:`

## Skills

Die folgenden Workflow-Kategorien sind im Einsatz:

- **KI-Agenten:** Claude/Anthropic + OpenAI via LangChain, Guardrails, Content-Erstellung, Brainstorming per Spracheingabe
- **Transkription (fonio):** Anruf-Transkripte nachbearbeiten, Persona-Generierung, Anrufercheck, E-Mail-Generierung aus Transkripten
- **Kommunikation:** Threema Work Gateway (Senden/Empfangen), Telegram Voice-to-Text, Gmail Inbox Management
- **Content & Daten:** YouTube-Transkripte nach Notion, LinkedIn-Scraping, Blogbeitrag-Erstellung
- **Infrastruktur:** Bidirektionaler GitHub-Sync (Backup + Restore), Workflow-Migration, Credential-Validierung

## Connectoren/APIs

| Connector | Verwendung | Haeufigkeit |
|-----------|-----------|-------------|
| Threema Gateway API | Nachrichten senden/empfangen, Benachrichtigungen | hoch |
| OpenAI / LangChain | KI-Agenten, Textverarbeitung, Guardrails | hoch |
| Anthropic (Claude) | KI-Agenten via LangChain | mittel |
| Notion API | Datenbanken, Seiten erstellen/aktualisieren | mittel |
| Telegram Bot API | Voice-Messages, Trigger, Benachrichtigungen | mittel |
| GitHub API | Workflow-Backup und Sync | mittel |
| Google Sheets | Datenimport/-export | mittel |
| YouTube API | Transkripte herunterladen | gering |
| DeepL API | Uebersetzungen | gering |
| IONOS E-Mail (SMTP) | E-Mail-Versand | gering |
| Gmail API | Inbox-Management | gering |
| Google Drive | Dateiverwaltung | gering |
