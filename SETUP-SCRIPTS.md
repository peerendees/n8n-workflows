# 🚀 Setup-Anleitung: Debug-Scripts verwenden

## Schritt 1: Voraussetzungen prüfen

### jq installieren (für JSON-Verarbeitung)

**macOS:**
```bash
brew install jq
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install jq
```

**Prüfen ob installiert:**
```bash
jq --version
```

### Scripts ausführbar machen

Die Scripts sollten bereits ausführbar sein. Falls nicht:
```bash
chmod +x export-execution.sh find-failed-executions.sh
```

---

## Schritt 2: n8n API-Key beschaffen

### Option A: Über n8n UI (Empfohlen)

1. **Öffne n8n:**
   ```
   https://n8n.srv1098810.hstgr.cloud
   ```

2. **Gehe zu Settings:**
   - Klicke auf dein Profil (oben rechts)
   - Wähle "Settings" oder "Einstellungen"

3. **API-Key erstellen:**
   - Suche nach "API" oder "API Keys"
   - Klicke auf "Create API Key" oder "API-Key erstellen"
   - Kopiere den generierten Key (wird nur einmal angezeigt!)

4. **Sicher speichern:**
   ```bash
   # Als Umgebungsvariable setzen (nur für diese Session)
   export N8N_API_KEY="dein-api-key-hier"
   
   # Oder dauerhaft in ~/.zshrc oder ~/.bashrc
   echo 'export N8N_API_KEY="dein-api-key-hier"' >> ~/.zshrc
   source ~/.zshrc
   ```

### Option B: Über n8n API (falls API-Key-Feature aktiviert)

Falls du bereits einen API-Key hast, kannst du ihn direkt verwenden.

---

## Schritt 3: Workflow-ID finden

### Option A: Über n8n UI

1. Öffne den Workflow "GitHub → n8n Synchronisation" in n8n
2. Die Workflow-ID steht in der URL:
   ```
   https://n8n.srv1098810.hstgr.cloud/workflow/12345
                                                      ^^^^^
                                                      Das ist die Workflow-ID
   ```

### Option B: Über list-workflows.sh Script

```bash
# Setze deine n8n URL
export N8N_URL="https://n8n.srv1098810.hstgr.cloud"
export N8N_API_KEY="dein-api-key"

# Führe das Script aus
./list-workflows.sh
```

Das Script zeigt alle Workflows mit ihren IDs an.

### Option C: Über n8n API direkt

```bash
curl -X GET \
  "https://n8n.srv1098810.hstgr.cloud/api/v1/workflows" \
  -H "X-N8N-API-KEY: dein-api-key" \
  | jq '.data[] | {id: .id, name: .name}'
```

---

## Schritt 4: Scripts verwenden

### 1. Fehlgeschlagene Executions finden

```bash
# Mit Umgebungsvariable
export N8N_API_KEY="dein-api-key"
./find-failed-executions.sh <workflow-id>

# Oder direkt als Parameter
./find-failed-executions.sh <workflow-id> 10 "dein-api-key"

# Beispiel
./find-failed-executions.sh 12345
```

**Ausgabe:**
- Liste aller fehlgeschlagenen Executions
- Gespeichert in `failed-executions-<workflow-id>.json`
- Zeigt Execution-IDs, die du dann exportieren kannst

### 2. Execution-Daten exportieren

```bash
# Mit Umgebungsvariable
export N8N_API_KEY="dein-api-key"
./export-execution.sh <execution-id>

# Oder direkt als Parameter
./export-execution.sh <execution-id> "dein-api-key"

# Beispiel
./export-execution.sh 67890
```

**Ausgabe:**
- Erstellt Verzeichnis: `debug-exports/<execution-id>/`
- Enthält:
  - `execution.json` - Komplette Execution-Daten
  - `nodes.json` - Alle Node-Daten
  - `errors.json` - Fehler-Details (falls vorhanden)
  - `workflow.json` - Workflow-Definition
  - `ZUSAMMENFASSUNG.md` - Übersicht

---

## Schritt 5: Vollständiger Workflow-Beispiel

```bash
# 1. API-Key setzen
export N8N_API_KEY="dein-api-key"

# 2. Workflow-ID finden (z.B. über UI oder list-workflows.sh)
WORKFLOW_ID="12345"

# 3. Fehlgeschlagene Executions finden
./find-failed-executions.sh $WORKFLOW_ID

# 4. Execution-ID aus der Ausgabe kopieren
EXECUTION_ID="67890"

# 5. Execution-Daten exportieren
./export-execution.sh $EXECUTION_ID

# 6. Ergebnisse ansehen
cat debug-exports/$EXECUTION_ID/ZUSAMMENFASSUNG.md
```

---

## Troubleshooting

### Problem: "jq nicht gefunden"

**Lösung:**
```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

### Problem: "HTTP 401 - Authentifizierung fehlgeschlagen"

**Mögliche Ursachen:**
1. API-Key falsch oder abgelaufen
2. API-Key-Feature nicht aktiviert in n8n

**Lösung:**
- Prüfe ob API-Key korrekt kopiert wurde
- Erstelle neuen API-Key in n8n Settings
- Prüfe ob API-Key-Feature in n8n aktiviert ist

### Problem: "HTTP 404 - Workflow nicht gefunden"

**Lösung:**
- Prüfe ob Workflow-ID korrekt ist
- Prüfe ob Workflow existiert (über n8n UI)
- Prüfe ob n8n URL korrekt ist

### Problem: "Script nicht ausführbar"

**Lösung:**
```bash
chmod +x export-execution.sh find-failed-executions.sh
```

---

## Nützliche Befehle

### Alle fehlgeschlagenen Executions eines Workflows exportieren

```bash
#!/bin/bash
# export-all-failed.sh

WORKFLOW_ID="$1"
API_KEY="$2"

# Finde alle fehlgeschlagenen Executions
./find-failed-executions.sh $WORKFLOW_ID 100 "$API_KEY"

# Extrahiere Execution-IDs
jq -r '.data[].id' failed-executions-${WORKFLOW_ID}.json | while read exec_id; do
    echo "Exportiere Execution: $exec_id"
    ./export-execution.sh $exec_id "$API_KEY"
done
```

### API-Key sicher speichern (macOS Keychain)

```bash
# Speichere API-Key im macOS Keychain
security add-generic-password \
  -a "n8n-api-key" \
  -s "n8n" \
  -w "dein-api-key"

# Abrufen
export N8N_API_KEY=$(security find-generic-password -a "n8n-api-key" -s "n8n" -w)
```

---

## Checkliste

- [ ] jq installiert (`jq --version`)
- [ ] Scripts ausführbar (`chmod +x *.sh`)
- [ ] n8n API-Key beschafft
- [ ] API-Key als Umgebungsvariable gesetzt oder gespeichert
- [ ] Workflow-ID gefunden
- [ ] `find-failed-executions.sh` erfolgreich getestet
- [ ] `export-execution.sh` erfolgreich getestet

---

## Nächste Schritte

Nachdem du die Debug-Daten exportiert hast:

1. **Analysiere die Fehler:**
   ```bash
   cat debug-exports/<execution-id>/ZUSAMMENFASSUNG.md
   cat debug-exports/<execution-id>/errors.json
   ```

2. **Prüfe Node-Daten:**
   ```bash
   # Zeige alle Node-Daten
   cat debug-exports/<execution-id>/nodes.json | jq 'keys'
   
   # Zeige spezifischen Node
   cat debug-exports/<execution-id>/nodes.json | jq '.["Parse Workflow"]'
   ```

3. **Teile die Informationen:**
   - Kopiere die relevanten Dateien
   - Oder teile die `ZUSAMMENFASSUNG.md` und `errors.json`

