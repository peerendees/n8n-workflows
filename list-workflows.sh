#!/bin/bash

# Script zum Auflisten aller n8n Workflows mit ihren IDs
# Verwendung: ./list-workflows.sh

# Konfiguration
N8N_URL="${N8N_URL:-http://localhost:5678}"
N8N_API_KEY="${N8N_API_KEY:-}"
N8N_USER="${N8N_USER:-}"
N8N_PASSWORD="${N8N_PASSWORD:-}"

# Farben für bessere Lesbarkeit
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== n8n Workflow Liste ===${NC}\n"

# Prüfe Verbindung
echo "Prüfe Verbindung zu $N8N_URL..."
if ! curl -s -f "$N8N_URL/healthz" > /dev/null 2>&1; then
    echo -e "${RED}Fehler: n8n ist nicht erreichbar unter $N8N_URL${NC}"
    echo -e "${YELLOW}Tipp: Stelle sicher, dass n8n läuft und die URL korrekt ist.${NC}"
    exit 1
fi

# Authentifizierung vorbereiten
AUTH_HEADERS=""
if [ -n "$N8N_API_KEY" ]; then
    echo -e "${GREEN}Verwende API Key Authentifizierung${NC}"
    AUTH_HEADERS="-H \"X-N8N-API-KEY: $N8N_API_KEY\""
elif [ -n "$N8N_USER" ] && [ -n "$N8N_PASSWORD" ]; then
    echo -e "${GREEN}Verwende Basic Auth${NC}"
    AUTH_HEADERS="-u \"$N8N_USER:$N8N_PASSWORD\""
else
    echo -e "${YELLOW}Hinweis: Keine Authentifizierung gesetzt.${NC}"
    echo -e "${YELLOW}Setze N8N_API_KEY oder N8N_USER/N8N_PASSWORD als Umgebungsvariablen.${NC}"
    echo -e "${YELLOW}Versuche ohne Authentifizierung...${NC}"
fi

# Hole alle Workflows
echo "Lade Workflows von $N8N_URL..."
RESPONSE=$(eval curl -s -X GET \
    "$N8N_URL/api/v1/workflows" \
    -H "Content-Type: application/json" \
    $AUTH_HEADERS)

# Prüfe ob Antwort erfolgreich war
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET \
    "$N8N_URL/api/v1/workflows" \
    -H "Content-Type: application/json" \
    $AUTH_HEADERS 2>/dev/null)

if [ "$HTTP_CODE" != "200" ]; then
    echo -e "${RED}Fehler: HTTP Status Code $HTTP_CODE${NC}"
    if [ "$HTTP_CODE" == "401" ]; then
        echo -e "${YELLOW}Authentifizierung fehlgeschlagen. Bitte Credentials prüfen.${NC}"
    elif [ "$HTTP_CODE" == "000" ]; then
        echo -e "${YELLOW}Konnte nicht verbinden. Prüfe ob n8n läuft.${NC}"
    fi
    echo -e "\n${YELLOW}Debug-Info:${NC}"
    echo "URL: $N8N_URL/api/v1/workflows"
    echo "Response: $RESPONSE"
    exit 1
fi

# Parse JSON und zeige Workflows
echo -e "\n${GREEN}Gefundene Workflows:${NC}\n"
echo "$RESPONSE" | python3 -c "
import json
import sys
from datetime import datetime

try:
    data = json.load(sys.stdin)
    workflows = data.get('data', [])
    
    if not workflows:
        print('Keine Workflows gefunden.')
        sys.exit(0)
    
    # Sortiere nach Name
    workflows.sort(key=lambda x: x.get('name', '').lower())
    
    print(f'{'ID':<20} {'Name':<50} {'Erstellt':<12} {'Aktualisiert':<12} {'Aktiv':<6}')
    print('-' * 110)
    
    for wf in workflows:
        wf_id = wf.get('id', 'N/A')
        name = wf.get('name', 'Unbenannt')
        active = '✓' if wf.get('active', False) else '✗'
        
        # Formatiere Datum
        created_at = wf.get('createdAt', '')
        updated_at = wf.get('updatedAt', '')
        
        if created_at:
            try:
                created_dt = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
                created_str = created_dt.strftime('%d.%m.%Y')
            except:
                created_str = created_at[:10] if len(created_at) >= 10 else created_at
        else:
            created_str = 'N/A'
        
        if updated_at:
            try:
                updated_dt = datetime.fromisoformat(updated_at.replace('Z', '+00:00'))
                updated_str = updated_dt.strftime('%d.%m.%Y')
            except:
                updated_str = updated_at[:10] if len(updated_at) >= 10 else updated_at
        else:
            updated_str = 'N/A'
        
        print(f'{wf_id:<20} {name:<50} {created_str:<12} {updated_str:<12} {active:<6}')
    
    print(f'\nGesamt: {len(workflows)} Workflow(s)')
    
except json.JSONDecodeError as e:
    print(f'Fehler beim Parsen der JSON-Antwort: {e}')
    print('Roh-Antwort:')
    print(sys.stdin.read())
    sys.exit(1)
except Exception as e:
    print(f'Fehler: {e}')
    sys.exit(1)
"

echo -e "\n${BLUE}=== Ende ===${NC}"

