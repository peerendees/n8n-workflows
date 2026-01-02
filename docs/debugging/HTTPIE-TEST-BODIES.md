# 🧪 HTTPie Test-Bodies für Hedy Webhook

## Test-Bodies für verschiedene Event-Typen

### 1. session.ended (für Transkripte)

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  Content-Type:application/json \
  event=session.ended \
  data:='{"id":"test_session_123","title":"Test YouTube Video","transcript":"Dies ist ein Test-Transkript. Das Video wurde erfolgreich transkribiert.","meeting_minutes":"1. Wichtiger Punkt\n2. Zweiter Punkt","conversations":"Q: Was wurde besprochen?\nA: Verschiedene Themen"}'
```

**Oder als JSON-Datei:**

```json
{
  "event": "session.ended",
  "data": {
    "id": "test_session_123",
    "title": "Test YouTube Video",
    "transcript": "Dies ist ein Test-Transkript. Das Video wurde erfolgreich transkribiert.",
    "meeting_minutes": "1. Wichtiger Punkt\n2. Zweiter Punkt",
    "conversations": "Q: Was wurde besprochen?\nA: Verschiedene Themen"
  },
  "timestamp": "2024-12-23T18:00:00Z"
}
```

**httpie Befehl:**
```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  < test-body.json
```

---

### 2. session.created (Session gestartet)

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  Content-Type:application/json \
  event=session.created \
  data:='{"id":"test_session_123","title":"Neue Session","startTime":"2024-12-23T18:00:00Z"}'
```

**JSON:**
```json
{
  "event": "session.created",
  "data": {
    "id": "test_session_123",
    "title": "Neue Session",
    "startTime": "2024-12-23T18:00:00Z"
  },
  "timestamp": "2024-12-23T18:00:00Z"
}
```

---

### 3. highlight.created (Highlight erstellt)

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  Content-Type:application/json \
  event=highlight.created \
  data:='{"title":"Wichtiger Punkt","mainIdea":"Dies ist die Hauptidee","cleanedQuote":"Zitat aus dem Transkript","rawQuote":"Original Zitat","aiInsight":"AI-generierte Erkenntnis","sessionId":"test_session_123"}'
```

**JSON:**
```json
{
  "event": "highlight.created",
  "data": {
    "title": "Wichtiger Punkt",
    "mainIdea": "Dies ist die Hauptidee",
    "cleanedQuote": "Zitat aus dem Transkript",
    "rawQuote": "Original Zitat",
    "aiInsight": "AI-generierte Erkenntnis",
    "sessionId": "test_session_123"
  },
  "timestamp": "2024-12-23T18:00:00Z"
}
```

---

### 4. todo.exported (Todo erstellt)

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  Content-Type:application/json \
  event=todo.exported \
  data:='{"id":"todo_123","text":"Workflow testen","dueDate":"2024-12-25","sessionId":"test_session_123"}'
```

**JSON:**
```json
{
  "event": "todo.exported",
  "data": {
    "id": "todo_123",
    "text": "Workflow testen",
    "dueDate": "2024-12-25",
    "sessionId": "test_session_123"
  },
  "timestamp": "2024-12-23T18:00:00Z"
}
```

---

## Einfache Test-Variante (minimal)

### Minimaler session.ended Body:

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  event=session.ended \
  data:='{"id":"test","title":"Test","transcript":"Test Transkript"}'
```

---

## Mit JSON-Datei (empfohlen)

### 1. Erstelle Datei `test-body.json`:

```json
{
  "event": "session.ended",
  "data": {
    "id": "test_session_123",
    "title": "Test YouTube Video",
    "transcript": "Dies ist ein Test-Transkript für die n8n Integration."
  },
  "timestamp": "2024-12-23T18:00:00Z"
}
```

### 2. Sende mit httpie:

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  < test-body.json
```

---

## Test mit verschiedenen Header-Formaten

### Format 1: Authorization Bearer (Standard)

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  event=session.ended \
  data:='{"id":"test","transcript":"test"}'
```

### Format 2: X-API-Key

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  X-API-Key:"DEIN_TOKEN" \
  event=session.ended \
  data:='{"id":"test","transcript":"test"}'
```

### Format 3: Authorization ohne Bearer

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"DEIN_TOKEN" \
  event=session.ended \
  data:='{"id":"test","transcript":"test"}'
```

---

## Vollständiger Test-Body (realistisch)

```json
{
  "event": "session.ended",
  "data": {
    "id": "sess_abc123xyz",
    "title": "n8n Tutorial - Neue Features",
    "startTime": "2024-12-23T17:00:00Z",
    "endTime": "2024-12-23T18:00:00Z",
    "duration": 60,
    "transcript": "In diesem Video besprechen wir die neuen Features von n8n. Zuerst schauen wir uns die neuen Nodes an. Dann gehen wir auf die Verbesserungen ein.",
    "meeting_minutes": "1. Neue Nodes vorgestellt\n2. Verbesserungen erklärt\n3. Best Practices diskutiert",
    "conversations": "Q: Welche neuen Features gibt es?\nA: Verschiedene neue Nodes und Verbesserungen."
  },
  "timestamp": "2024-12-23T18:00:00Z"
}
```

**httpie:**
```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer DEIN_TOKEN" \
  < full-test-body.json
```

---

## Quick Copy-Paste (minimal)

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos Authorization:"Bearer DEIN_TOKEN" event=session.ended data:='{"id":"test","title":"Test","transcript":"Test"}'
```

---

## Erwartete Antworten

### ✅ Erfolg (200 OK):
- Execution sollte in n8n erscheinen
- Eintrag sollte in Notion erstellt werden

### ❌ Fehler (403 Forbidden):
- "Authorization data is wrong!"
- → Header oder Token falsch

### ❌ Fehler (404 Not Found):
- Webhook nicht gefunden
- → URL oder Pfad falsch

