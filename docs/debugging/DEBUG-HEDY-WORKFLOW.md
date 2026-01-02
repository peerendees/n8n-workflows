# 🔍 Debug-Anleitung: Hedy Webhook to Notion 0.9

## Workflow-Informationen

- **Workflow-ID:** `p4WBXmtWQqToEtLw`
- **Name:** Hedy Webhook to Notion 0.9
- **Typ:** Webhook → Notion

## Workflow-Struktur

1. **Hedy API** (Webhook-Trigger)
   - Pfad: `Hedy-Todos`
   - Authentifizierung: Header Auth (GitHub Token)
   - Empfängt Webhook-Daten von Hedy

2. **Hedy Transkript 0.9** (Notion Node)
   - Erstellt Seite in Notion-Datenbank
   - Datenbank-ID: `2ca31cc6-fd56-8079-8a58-d74ec1097a36`
   - Titel: `{{ $json.body.event }}`
   - Transkript: `{{ $json.body.data.message }}`

---

## 🚀 Schnellstart: Debug-Daten sammeln

### Schritt 1: Fehlgeschlagene Executions finden

```bash
# Setze API-Key (falls noch nicht gesetzt)
export N8N_API_KEY="dein-api-key"

# Finde fehlgeschlagene Executions
./find-failed-executions.sh p4WBXmtWQqToEtLw
```

### Schritt 2: Execution-Daten exportieren

```bash
# Verwende eine Execution-ID aus Schritt 1
./export-execution.sh <execution-id>
```

### Schritt 3: Ergebnisse analysieren

```bash
# Zeige Zusammenfassung
cat debug-exports/<execution-id>/ZUSAMMENFASSUNG.md

# Zeige Fehler-Details
cat debug-exports/<execution-id>/errors.json

# Zeige Webhook-Daten
cat debug-exports/<execution-id>/nodes.json | jq '.["Hedy API"]'

# Zeige Notion-Node-Daten
cat debug-exports/<execution-id>/nodes.json | jq '.["Hedy Transkript 0.9"]'
```

---

## 🔍 Häufige Fehlerquellen

### 1. **Webhook-Authentifizierung**
- **Problem:** Header Auth verwendet "GitHub Token" (falsches Credential?)
- **Prüfen:** 
  - Ist das Credential korrekt konfiguriert?
  - Stimmt der Header-Name?
  - Wird der Token korrekt gesendet?

### 2. **Notion-Datenbank-Zugriff**
- **Problem:** Datenbank-ID oder Credentials falsch
- **Prüfen:**
  - Existiert die Datenbank-ID: `2ca31cc6-fd56-8079-8a58-d74ec1097a36`?
  - Sind die Notion-API-Credentials korrekt?
  - Hat der Notion-Integration Zugriff auf die Datenbank?

### 3. **Datenstruktur-Mismatch**
- **Problem:** Webhook sendet andere Datenstruktur als erwartet
- **Erwartet:**
  ```json
  {
    "body": {
      "event": "...",
      "data": {
        "message": "..."
      }
    }
  }
  ```
- **Prüfen:** 
  - Wie sieht der tatsächliche Webhook-Payload aus?
  - Stimmen die Pfade `$json.body.event` und `$json.body.data.message`?

### 4. **Notion-Property-Mapping**
- **Problem:** Property-Namen stimmen nicht
- **Erwartet:**
  - Property: `Titel|title`
  - Property: `Transkript|rich_text`
- **Prüfen:**
  - Existieren diese Properties in der Notion-Datenbank?
  - Stimmen die Typen (title, rich_text)?

---

## 📋 Checkliste für Fehleranalyse

- [ ] **Webhook empfängt Daten?**
  - Prüfe Node "Hedy API" Output
  - Ist `$json.body` vorhanden?
  - Wie sieht die Datenstruktur aus?

- [ ] **Notion-Credentials korrekt?**
  - Prüfe Credential-ID: `KpKj51GJ0big0oYv`
  - Ist der Notion-Integration Zugriff gewährt?

- [ ] **Datenbank existiert?**
  - Öffne: https://www.notion.so/2ca31cc6fd5680798a58d74ec1097a36
  - Ist die Datenbank erreichbar?

- [ ] **Properties existieren?**
  - Property "Titel" (Typ: title)
  - Property "Transkript" (Typ: rich_text)

- [ ] **Datenstruktur passt?**
  - `$json.body.event` existiert?
  - `$json.body.data.message` existiert?

---

## 🛠️ Manuelle Prüfung in n8n

### 1. Webhook testen

1. Öffne Workflow in n8n
2. Klicke auf "Hedy API" Node
3. Kopiere die Webhook-URL
4. Teste mit curl:
   ```bash
   curl -X POST \
     "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
     -H "Authorization: Bearer DEIN_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "body": {
         "event": "Test Event",
         "data": {
           "message": "Test Message"
         }
       }
     }'
   ```

### 2. Notion-Node testen

1. Öffne Workflow in n8n
2. Klicke auf "Hedy Transkript 0.9" Node
3. Führe Test-Execution aus
4. Prüfe Output-Daten

---

## 📊 Beispiel: Vollständiger Debug-Workflow

```bash
#!/bin/bash
# debug-hedy-workflow.sh

WORKFLOW_ID="p4WBXmtWQqToEtLw"
API_KEY="${N8N_API_KEY:-}"

if [ -z "$API_KEY" ]; then
    echo "Bitte N8N_API_KEY setzen"
    exit 1
fi

echo "🔍 Suche fehlgeschlagene Executions..."
./find-failed-executions.sh $WORKFLOW_ID

echo ""
echo "📥 Exportiere alle fehlgeschlagenen Executions..."

# Hole Execution-IDs aus der JSON-Datei
jq -r '.data[].id' failed-executions-${WORKFLOW_ID}.json | while read exec_id; do
    echo "Exportiere: $exec_id"
    ./export-execution.sh $exec_id
done

echo ""
echo "✅ Debug-Daten gespeichert in: debug-exports/"
```

---

## 🎯 Nächste Schritte

1. **Führe die Debug-Scripts aus:**
   ```bash
   export N8N_API_KEY="dein-api-key"
   ./find-failed-executions.sh p4WBXmtWQqToEtLw
   ```

2. **Exportiere die fehlgeschlagene Execution:**
   ```bash
   ./export-execution.sh <execution-id>
   ```

3. **Analysiere die Fehler:**
   - Öffne `debug-exports/<execution-id>/ZUSAMMENFASSUNG.md`
   - Prüfe `errors.json` für Fehlerdetails
   - Prüfe `nodes.json` für Node-Daten

4. **Teile die Ergebnisse:**
   - Kopiere die relevanten Dateien
   - Oder teile die Fehlermeldung und Node-Daten

---

## 💡 Tipps

- **Webhook-Payload prüfen:** Der häufigste Fehler ist eine falsche Datenstruktur
- **Notion-Integration:** Stelle sicher, dass die Integration Zugriff auf die Datenbank hat
- **Property-Namen:** Notion ist case-sensitive bei Property-Namen
- **Test-Execution:** Nutze die Test-Funktion in n8n, um einzelne Nodes zu testen

