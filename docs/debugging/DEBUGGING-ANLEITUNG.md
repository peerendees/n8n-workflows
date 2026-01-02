# 🔍 Debugging-Anleitung: GitHub → n8n Synchronisation

## Benötigte Informationen zur Fehleranalyse

### 1. **Fehlermeldung aus n8n**
- **Wo:** In der n8n UI → Workflow → "Executions" Tab
- **Was:** Die genaue Fehlermeldung vom fehlgeschlagenen Node
- **Wie sammeln:**
  - Öffne den fehlgeschlagenen Execution
  - Klicke auf den roten Node mit Fehler
  - Kopiere die Fehlermeldung komplett

### 2. **Execution-Logs (Node-Daten)**
- **Wo:** In der n8n UI → Workflow → "Executions" Tab
- **Was:** Die Input/Output-Daten jedes Nodes
- **Wie sammeln:**
  - Öffne den fehlgeschlagenen Execution
  - Klicke auf jeden Node (besonders die kritischen Nodes)
  - Klicke auf "Copy Output Data" oder "Copy Input Data"
  - Speichere die JSON-Daten

**Wichtige Nodes für diesen Workflow:**
- `Parse Workflow` - zeigt die geparsten Workflow-Daten
- `Prüfe ob Workflow existiert` - zeigt die HTTP-Response
- `Debug: Vor Erstellen` - zeigt die vorbereiteten Daten
- `Erstelle Workflow` / `Update Workflow` - zeigt die API-Response
- `Debug: Ergebnis` - zeigt das finale Ergebnis

### 3. **HTTP-Request Details**
- **Wo:** In den Node-Daten der HTTP Request Nodes
- **Was:** 
  - Request URL
  - Request Body (bei POST/PUT)
  - Response Status Code
  - Response Body
  - Headers (falls relevant)

### 4. **GitHub Webhook Payload**
- **Wo:** In der n8n UI → "GitHub Webhook Trigger" Node
- **Was:** Der komplette Webhook-Payload von GitHub
- **Wie sammeln:**
  - Öffne den Execution
  - Klicke auf "GitHub Webhook Trigger"
  - Kopiere die kompletten Input-Daten

### 5. **Workflow-Datei von GitHub**
- **Wo:** GitHub Repository
- **Was:** Die JSON-Datei, die synchronisiert werden soll
- **Wie sammeln:**
  - Öffne die Datei auf GitHub
  - Klicke auf "Raw" (roher Inhalt)
  - Kopiere den Inhalt oder lade die Datei herunter

---

## 📥 Informationen lokal sammeln

### Option 1: Über n8n UI (Empfohlen)

1. **Execution öffnen:**
   ```
   n8n UI → Workflows → "GitHub → n8n Synchronisation" → Executions Tab
   ```

2. **Fehlgeschlagene Execution finden:**
   - Suche nach roten Markierungen (Fehler)
   - Klicke auf die Execution

3. **Daten exportieren:**
   - Für jeden wichtigen Node:
     - Rechtsklick → "Copy Output Data"
     - Oder: Node öffnen → "Copy" Button
   - Speichere die JSON-Daten in separate Dateien

### Option 2: Über n8n API (Programmatisch)

#### Execution-Liste abrufen:
```bash
curl -X GET \
  "https://n8n.srv1098810.hstgr.cloud/api/v1/executions" \
  -H "X-N8N-API-KEY: DEIN_API_KEY" \
  -H "Content-Type: application/json"
```

#### Spezifische Execution abrufen:
```bash
EXECUTION_ID="deine-execution-id"

curl -X GET \
  "https://n8n.srv1098810.hstgr.cloud/api/v1/executions/$EXECUTION_ID" \
  -H "X-N8N-API-KEY: DEIN_API_KEY" \
  -H "Content-Type: application/json" \
  | jq '.' > execution-$EXECUTION_ID.json
```

#### Workflow-Daten abrufen:
```bash
WORKFLOW_ID="deine-workflow-id"

curl -X GET \
  "https://n8n.srv1098810.hstgr.cloud/api/v1/workflows/$WORKFLOW_ID" \
  -H "X-N8N-API-KEY: DEIN_API_KEY" \
  -H "Content-Type: application/json" \
  | jq '.' > workflow-$WORKFLOW_ID.json
```

### Option 3: GitHub-Dateien lokal klonen

```bash
# Repository klonen (falls noch nicht vorhanden)
git clone https://github.com/peerendees/n8n-workflows.git

# Oder: Aktualisieren
cd n8n-workflows
git pull origin main

# Spezifische Workflow-Datei anzeigen
cat n8n/WORKFLOW_NAME.json
```

---

## 📋 Checkliste für Fehleranalyse

Bitte sammle folgende Informationen:

- [ ] **Fehlermeldung:** Genauer Fehlertext aus n8n
- [ ] **Execution ID:** Die ID der fehlgeschlagenen Execution
- [ ] **GitHub Webhook Payload:** Komplette Webhook-Daten
- [ ] **Parse Workflow Output:** Was wurde aus der GitHub-Datei geparst?
- [ ] **Prüfe ob Workflow existiert Response:** HTTP-Response vom Check
- [ ] **Debug: Vor Erstellen Output:** Die vorbereiteten Daten vor dem Erstellen
- [ ] **Erstelle/Update Workflow Response:** Die API-Response von n8n
- [ ] **Debug: Ergebnis Output:** Das finale Ergebnis
- [ ] **GitHub-Datei:** Die JSON-Datei, die synchronisiert werden soll
- [ ] **Timestamp:** Wann ist der Fehler aufgetreten?

---

## 🛠️ Hilfreiche Scripts

### Script: Execution-Daten exportieren

```bash
#!/bin/bash
# export-execution.sh

N8N_URL="https://n8n.srv1098810.hstgr.cloud"
API_KEY="DEIN_API_KEY"
EXECUTION_ID="$1"

if [ -z "$EXECUTION_ID" ]; then
    echo "Usage: ./export-execution.sh <execution-id>"
    exit 1
fi

# Erstelle Export-Verzeichnis
mkdir -p "debug-exports/$EXECUTION_ID"

# Hole Execution-Daten
curl -X GET \
  "$N8N_URL/api/v1/executions/$EXECUTION_ID" \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Content-Type: application/json" \
  | jq '.' > "debug-exports/$EXECUTION_ID/execution.json"

echo "✅ Execution-Daten exportiert nach: debug-exports/$EXECUTION_ID/"
```

### Script: Alle fehlgeschlagenen Executions finden

```bash
#!/bin/bash
# find-failed-executions.sh

N8N_URL="https://n8n.srv1098810.hstgr.cloud"
API_KEY="DEIN_API_KEY"
WORKFLOW_ID="$1"

if [ -z "$WORKFLOW_ID" ]; then
    echo "Usage: ./find-failed-executions.sh <workflow-id>"
    exit 1
fi

# Hole fehlgeschlagene Executions
curl -X GET \
  "$N8N_URL/api/v1/executions?workflowId=$WORKFLOW_ID&status=error&limit=10" \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Content-Type: application/json" \
  | jq '.data[] | {id: .id, finishedAt: .finishedAt, stoppedAt: .stoppedAt}' \
  > failed-executions.json

echo "✅ Fehlgeschlagene Executions gespeichert in: failed-executions.json"
```

---

## 📝 Beispiel: Strukturierte Fehleranalyse

Wenn du die Informationen gesammelt hast, erstelle eine Datei mit folgendem Format:

```json
{
  "executionId": "12345",
  "timestamp": "2024-01-15T10:30:00Z",
  "error": {
    "node": "Erstelle Workflow",
    "message": "HTTP 400: Bad Request",
    "details": "..."
  },
  "inputData": {
    "githubWebhook": {...},
    "parsedWorkflow": {...},
    "workflowData": {...}
  },
  "outputData": {
    "checkWorkflowExists": {...},
    "createWorkflow": {...}
  },
  "githubFile": {
    "path": "n8n/test-workflow.json",
    "content": "..."
  }
}
```

---

## 🚀 Schnellstart

**Am schnellsten geht es so:**

1. Öffne n8n UI → Workflow → Executions
2. Finde die fehlgeschlagene Execution
3. Klicke auf jeden Node und kopiere die Output-Daten
4. Speichere alles in einer Datei: `debug-info.json`
5. Teile diese Datei für die Analyse

**Oder nutze die API:**

```bash
# Setze deine Werte
EXECUTION_ID="deine-execution-id"
API_KEY="dein-api-key"

# Exportiere alles
curl -X GET \
  "https://n8n.srv1098810.hstgr.cloud/api/v1/executions/$EXECUTION_ID" \
  -H "X-N8N-API-KEY: $API_KEY" \
  | jq '.' > debug-info.json
```

