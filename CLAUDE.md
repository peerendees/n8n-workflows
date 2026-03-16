# CLAUDE.md — AI Assistant Guide for n8n-workflows

## Repository Overview

This repository manages **n8n workflow automation** with bidirectional GitHub sync. It contains:
- Exported n8n workflow JSON files (auto-backed-up from a Hostinger-hosted n8n instance)
- Docker Compose configs for local n8n development
- Shell scripts for workflow management and database backups
- Comprehensive German-language documentation

**Primary language of docs and commit messages: German.**

## Repository Structure

```
n8n-workflows/
├── n8n/                          # Auto-backed-up workflows (by workflow ID)
│   └── {workflowId}/
│       └── {workflowId}.json     # n8n workflow export (36 workflows)
├── workflows/                    # Categorized workflow templates & references
│   ├── ai-agents/                # AI agent workflows
│   ├── analysis/                 # Data analysis workflows
│   ├── business/                 # Business process workflows
│   ├── communication/            # Threema, Gmail, messaging workflows
│   ├── content-automation/       # Content creation workflows
│   ├── fieck/                    # "Fieckscher Feger" project workflows
│   ├── fonio/                    # Fonio training persona workflows
│   └── linkedIn-scraper/         # LinkedIn scraping workflows
├── docs/                         # Documentation (German)
│   ├── setup/                    # Multi-computer setup guides & scripts
│   ├── workflows/                # Workflow-specific documentation
│   ├── notion/                   # Notion integration docs
│   ├── debugging/                # Debugging & troubleshooting guides
│   └── README.md                 # Documentation index
├── archived_root_files/          # Old/migrated workflow files
├── docker-compose.yml            # Local n8n (stable, port 5678, SQLite)
├── docker-compose.beta.yml       # Beta n8n (port 5679, SQLite)
├── init.sql                      # PostgreSQL schema (Threema GDPR-compliant)
├── backup.sh                     # Database backup script
├── list-workflows.sh             # List n8n workflows via API
├── find-failed-executions.sh     # Find failed workflow executions
├── export-execution.sh           # Export execution data
├── BEST_PRACTICES.md             # Sync/backup best practices
├── config                        # n8n encryption key (JSON) — sensitive
└── compiled-n8n-docs.docx        # Compiled n8n documentation reference
```

## Key Concepts

### Workflow Storage
- **`n8n/` directory**: Each workflow is stored in a folder named by its n8n workflow ID, containing a single JSON file with the same ID as filename. This is the **primary backup location** used by the auto-backup n8n workflow.
- **`workflows/` directory**: Manually organized workflow templates grouped by category. These are reference/template files, not live backups.
- Workflow JSON files follow n8n's export format with `name`, `active`, `nodes`, `connections`, and `settings` fields.

### Bidirectional Sync Architecture
- **n8n → GitHub (Backup)**: An n8n workflow automatically backs up all workflows to the `n8n/` directory via GitHub push. Commits follow the pattern: `🤖 Auto-Backup: {Workflow Name} (ID: {workflowId})`
- **GitHub → n8n (Sync)**: A GitHub webhook triggers an n8n workflow that pulls changes into the n8n instance.
- **Race condition risk**: See `BEST_PRACTICES.md` — GitHub is the master for logic/code, n8n is the master for runtime/triggers.

### Docker Setup
- **Stable**: `docker-compose.yml` — n8n v1.115.2 on port 5678, SQLite, timezone Europe/Berlin
- **Beta**: `docker-compose.beta.yml` — n8n v1.119.1 on port 5679 (parallel testing)
- Both use ngrok for webhook access (`oriented-sincere-robin.ngrok-free.app`)
- Data volumes: `./data` (stable) and `./data-beta` (beta) — both gitignored

### Database
- `init.sql` defines a PostgreSQL schema for Threema messaging with GDPR compliance (schemas: `threema_data`, `audit_log`)
- Local n8n instances use SQLite (not PostgreSQL)

## Development Workflow

### Editing Workflows
1. **Preferred**: Edit workflows in the n8n UI → changes are auto-backed-up to GitHub every 15 minutes
2. **Alternative**: Edit JSON files in the repo → push to GitHub → webhook triggers sync to n8n
3. When modifying backup/sync workflows, **deactivate the backup workflow first** to avoid race conditions

### Git Conventions
- **Commit messages**: German language, descriptive. Auto-backup commits use emoji prefix `🤖`
- **Branch**: `main` is the default branch
- **Multi-computer workflow**: Changes are pushed/pulled from a shared directory (`/Users/Shared/n8n-workflows` on macOS)

### Shell Scripts
All scripts are Bash. Key environment variables:
- `N8N_URL` — n8n instance URL (default: `http://localhost:5678`)
- `N8N_API_KEY` — API key for authentication
- `N8N_USER` / `N8N_PASSWORD` — Basic auth credentials

## Important Files to Know

| File | Purpose |
|------|---------|
| `BEST_PRACTICES.md` | Sync architecture & race condition prevention |
| `docker-compose.yml` | Local n8n stable instance config |
| `init.sql` | GDPR-compliant Threema database schema |
| `config` | n8n encryption key — **do not commit changes or expose** |
| `.gitignore` | Excludes `data/`, `.env`, `backups/`, SQLite files |

## Rules for AI Assistants

1. **Do not modify files in `n8n/`** unless explicitly asked — these are auto-managed by the backup workflow and will be overwritten.
2. **Do not modify or expose `config`** — it contains the n8n encryption key.
3. **Do not commit `.env` files or credentials** — they are gitignored for a reason.
4. **Write documentation and commit messages in German** to match the existing style.
5. **Workflow JSON files are n8n exports** — do not hand-edit node IDs, connections, or internal metadata unless you understand the n8n JSON format.
6. **Respect the sync architecture**: GitHub is the source of truth for workflow logic. When suggesting workflow changes, prefer editing the JSON in the repo and letting the sync workflow deploy it.
7. **Docker credentials in `docker-compose.yml` are for local dev only** — do not treat them as production secrets, but also don't add real credentials there.
8. **The `workflows/` directory uses descriptive names** while `n8n/` uses opaque IDs — check both when searching for a specific workflow.
