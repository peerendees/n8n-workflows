#!/bin/bash
# Exportiert Execution-Daten von n8n für Debugging

# Konfiguration
N8N_URL="https://n8n.srv1098810.hstgr.cloud"
API_KEY="${N8N_API_KEY:-}"  # Kann als Umgebungsvariable gesetzt werden

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Prüfe ob Execution-ID übergeben wurde
if [ -z "$1" ]; then
    echo -e "${RED}Fehler: Keine Execution-ID angegeben${NC}"
    echo ""
    echo "Usage: $0 <execution-id> [api-key]"
    echo ""
    echo "Beispiel:"
    echo "  $0 12345"
    echo "  N8N_API_KEY=dein-key $0 12345"
    exit 1
fi

EXECUTION_ID="$1"

# API-Key prüfen
if [ -z "$API_KEY" ] && [ -n "$2" ]; then
    API_KEY="$2"
fi

if [ -z "$API_KEY" ]; then
    echo -e "${YELLOW}Warnung: Kein API-Key gesetzt${NC}"
    echo "Setze N8N_API_KEY als Umgebungsvariable oder gib ihn als zweiten Parameter an"
    echo ""
    read -p "API-Key eingeben (oder Enter zum Abbrechen): " API_KEY
    if [ -z "$API_KEY" ]; then
        echo "Abgebrochen."
        exit 1
    fi
fi

# Erstelle Export-Verzeichnis
EXPORT_DIR="debug-exports/$EXECUTION_ID"
mkdir -p "$EXPORT_DIR"

echo -e "${GREEN}📥 Exportiere Execution-Daten...${NC}"
echo "Execution ID: $EXECUTION_ID"
echo "Export-Verzeichnis: $EXPORT_DIR"
echo ""

# Hole Execution-Daten
echo "Lade Execution-Daten..."
HTTP_CODE=$(curl -s -w "%{http_code}" -o "$EXPORT_DIR/execution.json" \
  -X GET \
  "$N8N_URL/api/v1/executions/$EXECUTION_ID" \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Content-Type: application/json")

if [ "$HTTP_CODE" != "200" ]; then
    echo -e "${RED}Fehler: HTTP Status Code $HTTP_CODE${NC}"
    if [ "$HTTP_CODE" == "401" ]; then
        echo -e "${YELLOW}Authentifizierung fehlgeschlagen. Bitte API-Key prüfen.${NC}"
    elif [ "$HTTP_CODE" == "404" ]; then
        echo -e "${YELLOW}Execution nicht gefunden. Bitte Execution-ID prüfen.${NC}"
    fi
    rm -rf "$EXPORT_DIR"
    exit 1
fi

# Prüfe ob jq installiert ist
if command -v jq &> /dev/null; then
    # Formatiere JSON schön
    jq '.' "$EXPORT_DIR/execution.json" > "$EXPORT_DIR/execution-formatted.json"
    mv "$EXPORT_DIR/execution-formatted.json" "$EXPORT_DIR/execution.json"
    
    # Extrahiere wichtige Informationen
    echo "Extrahiere wichtige Informationen..."
    
    # Workflow-ID
    WORKFLOW_ID=$(jq -r '.workflowId // empty' "$EXPORT_DIR/execution.json")
    if [ -n "$WORKFLOW_ID" ] && [ "$WORKFLOW_ID" != "null" ]; then
        echo "Workflow ID: $WORKFLOW_ID"
        
        # Hole Workflow-Daten
        echo "Lade Workflow-Daten..."
        curl -s -X GET \
          "$N8N_URL/api/v1/workflows/$WORKFLOW_ID" \
          -H "X-N8N-API-KEY: $API_KEY" \
          -H "Content-Type: application/json" \
          | jq '.' > "$EXPORT_DIR/workflow.json"
    fi
    
    # Status
    STATUS=$(jq -r '.finished // false' "$EXPORT_DIR/execution.json")
    echo "Status: $STATUS"
    
    # Fehler-Informationen
    ERROR_COUNT=$(jq '[.data.resultData.error[]?] | length' "$EXPORT_DIR/execution.json")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}Fehler gefunden: $ERROR_COUNT${NC}"
        jq '.data.resultData.error' "$EXPORT_DIR/execution.json" > "$EXPORT_DIR/errors.json"
    fi
    
    # Node-Daten extrahieren
    echo "Extrahiere Node-Daten..."
    jq '.data.resultData.runData' "$EXPORT_DIR/execution.json" > "$EXPORT_DIR/nodes.json"
    
    # Erstelle Zusammenfassung
    cat > "$EXPORT_DIR/ZUSAMMENFASSUNG.md" << EOF
# Execution-Debug-Informationen

**Execution ID:** $EXECUTION_ID  
**Exportiert am:** $(date)  
**Status:** $STATUS

## Fehler
EOF
    
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "**Anzahl Fehler:** $ERROR_COUNT" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
        echo "" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
        echo "### Fehler-Details" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
        echo '```json' >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
        jq '.' "$EXPORT_DIR/errors.json" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
        echo '```' >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
    else
        echo "Keine Fehler gefunden." >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
    fi
    
    echo "" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
    echo "## Dateien" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
    echo "- \`execution.json\` - Komplette Execution-Daten" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
    echo "- \`nodes.json\` - Alle Node-Daten" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
    if [ -f "$EXPORT_DIR/errors.json" ]; then
        echo "- \`errors.json\` - Fehler-Details" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
    fi
    if [ -f "$EXPORT_DIR/workflow.json" ]; then
        echo "- \`workflow.json\` - Workflow-Definition" >> "$EXPORT_DIR/ZUSAMMENFASSUNG.md"
    fi
fi

echo ""
echo -e "${GREEN}✅ Export abgeschlossen!${NC}"
echo ""
echo "Exportierte Dateien:"
ls -lh "$EXPORT_DIR"
echo ""
echo "Öffne die Zusammenfassung:"
echo "  cat $EXPORT_DIR/ZUSAMMENFASSUNG.md"

