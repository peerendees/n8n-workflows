#!/usr/bin/env bash
# Erstellt einen Workflow in n8n per REST-API.
#
# Der API-Key kommt NUR aus der Umgebung oder aus lokaler .env / .env.local
# (beides gitignored) — niemals in Git committen.
#
# Voraussetzung: jq (brew install jq)
#
# Verwendung:
#   ./import-workflow-to-n8n.sh drafts/cursor-done-rueckkanal.json

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

load_env_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  set -a
  # shellcheck disable=SC1090
  source "$f"
  set +a
}

load_env_file ".env"
load_env_file ".env.local"

N8N_URL="${N8N_URL:-https://n8n.srv1098810.hstgr.cloud}"
N8N_API_KEY="${N8N_API_KEY:-}"

if [[ -z "$N8N_API_KEY" ]]; then
  echo "Fehler: N8N_API_KEY ist nicht gesetzt." >&2
  echo "" >&2
  echo "Hinweis: Ein Secret in GitHub ist nur für Workflows auf github.com sichtbar." >&2
  echo "Dieses Skript läuft auf deinem Rechner — es kann GitHub-Secrets nicht lesen." >&2
  echo "Den Key nimmst du aus n8n: Einstellungen → API." >&2
  echo "" >&2
  echo "Lokal einrichten (eine der beiden Varianten):" >&2
  echo "  1) cp .env.example .env  und in .env: N8N_API_KEY=<Key aus n8n>" >&2
  echo "  2) export N8N_API_KEY='<Key aus n8n>'" >&2
  exit 1
fi

JSON_FILE="${1:-}"
if [[ -z "$JSON_FILE" ]]; then
  echo "Verwendung: $0 <pfad/zum/workflow.json>" >&2
  exit 1
fi

if [[ ! -f "$JSON_FILE" ]]; then
  echo "Datei nicht gefunden: $JSON_FILE" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Fehler: jq ist nicht installiert (z. B. brew install jq)." >&2
  exit 1
fi

TMP_PAYLOAD="$(mktemp)"
TMP_RESP="$(mktemp)"
trap 'rm -f "$TMP_PAYLOAD" "$TMP_RESP"' EXIT

# Neuen Workflow anlegen: n8n POST /workflows erlaubt nur Kernfelder — Exporte enthalten oft
# meta, pinData, tags … die API mit "must NOT have additional properties" ablehnt.
# "active" ist bei POST read-only (Workflow ist bis zur Aktivierung in der UI inaktiv).
jq 'del(.id, .versionId, .meta, .pinData, .tags, .active)' "$JSON_FILE" >"$TMP_PAYLOAD"

HTTP_CODE="$(
  curl -sS -o "$TMP_RESP" -w "%{http_code}" -X POST "$N8N_URL/api/v1/workflows" \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    -H "Content-Type: application/json" \
    --data-binary @"$TMP_PAYLOAD"
)"

if [[ "$HTTP_CODE" != "200" && "$HTTP_CODE" != "201" ]]; then
  echo "n8n API Fehler: HTTP $HTTP_CODE" >&2
  cat "$TMP_RESP" >&2
  exit 1
fi

echo "OK — Workflow angelegt (HTTP $HTTP_CODE)."
jq 'if type == "object" and has("data") then .data else . end' "$TMP_RESP" 2>/dev/null || cat "$TMP_RESP"
