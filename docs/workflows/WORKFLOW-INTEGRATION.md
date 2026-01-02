# 🔗 Workflow-Integration: Fehlende Nodes hinzufügen

## Aktueller Stand

✅ **Webhook-Node:** Konfiguriert mit "Hedy Webhook Auth"
❌ **Parse-Node:** Fehlt
❌ **Notion-Node:** Fehlt oder nicht vollständig

---

## Komplette Node-Struktur

### Node 1: Hedy API (Webhook) ✅
**Bereits vorhanden** - Credential korrekt!

### Node 2: Parse Hedy Daten (Code Node) ❌
**Fehlt noch!**

**Hinzufügen:**
1. Code-Node hinzufügen
2. Name: "Parse Hedy Daten"
3. Code einfügen (siehe unten)

### Node 3: Hedy Transkript 0.9 (Notion) ❌
**Fehlt noch oder unvollständig!**

**Hinzufügen:**
1. Notion-Node hinzufügen
2. Properties konfigurieren (siehe unten)

---

## Node 2: Parse Hedy Daten (Code Node)

**Type:** Code
**Name:** Parse Hedy Daten
**Position:** Rechts vom Webhook-Node

**Code:**
```javascript
// Parse Hedy Webhook-Daten und normalisiere für Notion (Option 2)
// Die Hedy API sendet Daten direkt im Root, nicht in 'body'
const webhookData = $json;

// Extrahiere Event-Typ und Daten
const eventType = webhookData.event || '';
const eventData = webhookData.data || {};
const timestamp = webhookData.timestamp || new Date().toISOString();

// Bestimme Werte je nach Event-Typ
let title = '';
let summary = '';
let content = '';
let sessionId = null;
let sessionTitle = null;
let dueDate = null;
let status = null;

if (eventType.startsWith('session.')) {
  // Session-Events: session.created, session.ended
  title = eventData.title || `Session ${eventData.id || ''}`;
  summary = eventData.meeting_minutes || eventData.title || '';
  content = eventData.transcript || 
            eventData.meeting_minutes || 
            eventData.conversations || 
            `Session ${eventType} - ${timestamp}`;
  sessionId = eventData.id || null;
  sessionTitle = eventData.title || null;
  
} else if (eventType === 'highlight.created') {
  // Highlight-Events
  title = eventData.title || 'Highlight';
  summary = eventData.mainIdea || eventData.title || '';
  
  const parts = [];
  if (eventData.mainIdea) parts.push(`**Hauptidee:** ${eventData.mainIdea}`);
  if (eventData.cleanedQuote) parts.push(`**Zitat:** ${eventData.cleanedQuote}`);
  if (eventData.rawQuote && eventData.rawQuote !== eventData.cleanedQuote) {
    parts.push(`**Original:** ${eventData.rawQuote}`);
  }
  if (eventData.aiInsight) parts.push(`**AI Insight:** ${eventData.aiInsight}`);
  content = parts.join('\n\n') || 'Keine Details verfügbar';
  
  sessionId = eventData.sessionId || null;
  
} else if (eventType === 'todo.exported') {
  // Todo-Events - WICHTIG: data.text statt data.message!
  title = eventData.text || 'Unnamed Todo';
  summary = eventData.dueDate || '';
  status = 'offen'; // Standard-Status für neue Todos
  
  const parts = [];
  parts.push(`**Text:** ${eventData.text || ''}`);
  if (eventData.dueDate) {
    parts.push(`**Fälligkeitsdatum:** ${eventData.dueDate}`);
  }
  if (eventData.sessionId) parts.push(`**Session ID:** ${eventData.sessionId}`);
  if (eventData.id) parts.push(`**Todo ID:** ${eventData.id}`);
  content = parts.join('\n');
  
  sessionId = eventData.sessionId || null;
  
} else {
  // Unbekanntes Event - Fallback
  title = `Unknown Event: ${eventType || 'N/A'}`;
  summary = '';
  content = `**Event-Typ:** ${eventType}\n\n**Daten:**\n\n\`\`\`json\n${JSON.stringify(eventData, null, 2)}\n\`\`\``;
}

return {
  json: {
    eventType: eventType,
    title: title,
    summary: summary,
    content: content,
    timestamp: timestamp,
    sessionId: sessionId || '',
    sessionTitle: sessionTitle || '',
    dueDate: dueDate || '',
    status: status || '',
    // Behalte originale Daten für Debugging
    rawData: webhookData
  }
};
```

---

## Node 3: Hedy Transkript 0.9 (Notion Node)

**Type:** Notion
**Name:** Hedy Transkript 0.9
**Position:** Rechts vom Parse-Node

**Konfiguration:**

**Resource:** Database Page
**Operation:** Create
**Database:** By ID → `2ca31cc6-fd56-8079-8a58-d74ec1097a36` (oder deine neue DB-ID)
**Title:** Hedy Transkript

**Properties (8 Stück):**

1. **Titel** (title):
   - Expression: `{{ $json.title }}`

2. **Event-Typ** (select):
   - Expression: `{{ $json.eventType }}`

3. **Status** (select):
   - Expression: `{{ $json.status || '' }}`

4. **Transkript** (rich_text):
   - Expression: `{{ $json.content }}`

5. **Session ID** (text):
   - Expression: `{{ $json.sessionId }}`

6. **Session Titel** (text):
   - Expression: `{{ $json.sessionTitle }}`

7. **Erstellungsdatum** (date):
   - Expression: `{{ $json.timestamp }}`

8. **Due Date** (date):
   - Expression: `{{ $json.dueDate || '' }}`

---

## Connections (Verknüpfungen)

**Hedy API** → **Parse Hedy Daten** → **Hedy Transkript 0.9**

1. Webhook-Node Output → Parse-Node Input
2. Parse-Node Output → Notion-Node Input

---

## Schnelllösung: Kompletten Workflow importieren

**Am einfachsten:**

1. `Hedy Webhook to Notion 0.9 - OPTIMIZED.json` öffnen
2. Kompletten Inhalt kopieren
3. In n8n: Workflows → Import from File
4. JSON einfügen
5. **Wichtig:** Database ID anpassen (falls nötig)
6. Credentials prüfen (sollten bereits korrekt sein)
7. Workflow aktivieren

---

## Manuelle Integration

Falls du die Nodes manuell hinzufügen willst:

1. **Code-Node hinzufügen:**
   - Code von oben einfügen
   - Name: "Parse Hedy Daten"

2. **Notion-Node hinzufügen:**
   - Properties wie oben konfigurieren

3. **Connections erstellen:**
   - Webhook → Parse → Notion

4. **Testen:**
   - Test-Webhook senden
   - Prüfen ob Execution funktioniert

