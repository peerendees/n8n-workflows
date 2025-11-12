# n8n Setup Dokumentation

## Aktuelle Konfiguration
- Basis: SQLite (vereinfachte Version)
- Workspace: `/Users/kunkel/n8n-workflows`
- **Stabile Version:** n8nio/n8n:1.115.2 (Port 5678)
- **Beta Version:** n8nio/n8n:1.119.1 (Port 5679)

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

### Stabile Version (1.115.2) auf Port 5678
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

### Beta Version (1.119.1) auf Port 5679
```bash
# Start
docker-compose -f docker-compose.beta.yml up -d

# Stop
docker-compose -f docker-compose.beta.yml down

# Logs anzeigen
docker-compose -f docker-compose.beta.yml logs -f

# Zugriff im Browser
http://localhost:5679
```

### Beide Versionen parallel laufen lassen
```bash
# Starte beide Versionen
docker-compose up -d
docker-compose -f docker-compose.beta.yml up -d

# Stabile Version: http://localhost:5678
# Beta Version: http://localhost:5679
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