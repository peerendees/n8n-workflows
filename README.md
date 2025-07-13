# n8n Setup Dokumentation

## Aktuelle Konfiguration
- Basis: SQLite (vereinfachte Version)
- Workspace: `/Users/kunkel/n8n-workflows`
- Docker Image: n8nio/n8n:latest

## Verzeichnisstruktur
```
n8n-workflows/
├── workflows/          # Kategorisierte n8n Workflows
│   ├── ai-agents/
│   ├── communication/
│   ├── business/
│   └── analysis/
├── docker-compose.yml  # Vereinfachte SQLite-Version
└── .gitignore         # Ignoriert Logs und temporäre Dateien
```

## Docker Setup
```yaml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/home/node/.n8n/workflows
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=DEIN_PASSWORT
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - DB_TYPE=sqlite
      - DB_SQLITE_PATH=/home/node/.n8n/database.sqlite

volumes:
  n8n_data:
```

## Wichtige Befehle
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Logs anzeigen
docker-compose logs -f

# Backup erstellen
docker-compose exec n8n n8n export:workflow --all --output=workflows/backup/

# Workflow importieren
docker-compose exec n8n n8n import:workflow --input=workflows/mein-workflow.json
```

## GitHub Repository
- Repository: peerendees/n8n-workflows
- Branch: main
- Workflows werden in kategorisierten Unterordnern gespeichert

## Nächste Schritte
1. Repository klonen: `git clone https://github.com/peerendees/n8n-workflows.git`
2. In Verzeichnis wechseln: `cd n8n-workflows`
3. Docker Compose starten
4. n8n im Browser öffnen: http://localhost:5678

## Wichtige Links
- n8n Docs: https://docs.n8n.io/
- Docker Hub: https://hub.docker.com/r/n8nio/n8n
- GitHub Repo: https://github.com/peerendees/n8n-workflows 