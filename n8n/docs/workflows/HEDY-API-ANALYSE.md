# 🔍 Hedy API Webhook-Format Analyse

## Webhook-Event-Struktur (laut API-Dokumentation)

Die Hedy API sendet Webhooks im folgenden Format:

```json
{
  "event": "session.created" | "session.ended" | "highlight.created" | "todo.exported",
  "data": {
    // Unterschiedliche Struktur je nach Event-Typ (oneOf)
  },
  "timestamp": "2024-03-15T14:30:00Z"
}
```

**WICHTIG:** Die Daten kommen **direkt im Root**, nicht in `body`!

---

## Unterschiedliche Event-Typen und ihre Datenstrukturen

### 1. `session.created` / `session.ended`
**Datenstruktur:**
```json
{
  "event": "session.created",
  "data": {
    "id": "sess_123456789",
    "title": "Weekly Team Sync",
    "startTime": "2024-03-15T14:30:00Z",
    "endTime": "2024-03-15T15:15:00Z",
    "duration": 45,
    "transcript": "John: Let's review our progress...",
    "conversations": "Q: What's the status?\nA: On track...",
    "meeting_minutes": "1. Project ..."
  },
  "timestamp": "2024-03-15T14:30:00Z"
}
```

**Verfügbare Felder:**
- `data.transcript` - Vollständiges Transkript
- `data.title` - Meeting-Titel
- `data.conversations` - Strukturierte Gesprächshistorie
- `data.meeting_minutes` - Formatierte Meeting-Minuten

---

### 2. `highlight.created`
**Datenstruktur:**
```json
{
  "event": "highlight.created",
  "data": {
    "id": "123456789",
    "sessionId": "123456789",
    "timestamp": "2024-03-15T14:35:00Z",
    "timeIndex": 300000,
    "title": "Key Decision on Mobile App",
    "rawQuote": "yeah I think we should prioritize the mobile app",
    "cleanedQuote": "We should prioritize the mobile app",
    "mainIdea": "Team agreed to prioritize mobile app development",
    "aiInsight": "Strategic prioritization of mobile platform"
  },
  "timestamp": "2024-03-15T14:35:00Z"
}
```

**Verfügbare Felder:**
- `data.title` - Highlight-Titel
- `data.mainIdea` - Hauptidee
- `data.cleanedQuote` - Bereinigtes Zitat
- `data.rawQuote` - Rohes Zitat
- `data.aiInsight` - AI-Insight

---

### 3. `todo.exported`
**Datenstruktur:**
```json
{
  "event": "todo.exported",
  "data": {
    "sessionId": "sess_123456789",
    "text": "Finalize the project proposal",
    "id": "uuid-1234-abcd-5678",
    "dueDate": "May 18, 2027 3pm"
  },
  "timestamp": "2024-03-15T14:30:00Z"
}
```

**Verfügbare Felder:**
- `data.text` - Todo-Text (⚠️ NICHT `message`!)
- `data.id` - Todo-ID
- `data.dueDate` - Fälligkeitsdatum
- `data.sessionId` - Session-ID

---

## ❌ Problem im aktuellen Workflow

Der aktuelle Workflow verwendet:
```javascript
$json.body.event        // ❌ FALSCH - sollte $json.event sein
$json.body.data.message // ❌ FALSCH - existiert nicht!
```

**Probleme:**
1. `body` existiert nicht - Daten kommen direkt im Root
2. `data.message` existiert nicht - bei Todos heißt es `data.text`
3. Keine Unterscheidung zwischen verschiedenen Event-Typen

---

## ✅ Lösung: Workflow anpassen

Der Workflow muss:
1. Direkt `$json.event` verwenden (nicht `$json.body.event`)
2. Je nach Event-Typ unterschiedliche Felder extrahieren:
   - `session.*`: `data.transcript` oder `data.title`
   - `highlight.*`: `data.title` oder `data.mainIdea`
   - `todo.exported`: `data.text` (nicht `message`!)
3. Optional: Event-Typ prüfen und unterschiedlich verarbeiten

---

## 📋 Empfohlene Workflow-Struktur

```
1. Webhook empfängt Daten
   ↓
2. Code Node: Parse und normalisiere Daten
   - Extrahiere event-Typ
   - Extrahiere relevante Daten je nach Event-Typ
   - Erstelle einheitliches Format für Notion
   ↓
3. Notion Node: Erstelle Seite
   - Titel: Event-Typ + relevante Info
   - Inhalt: Je nach Event-Typ unterschiedlich
```

---

## 🔧 Beispiel-Code für Parsing-Node

```javascript
// Parse Hedy Webhook-Daten
const webhookData = $json;

// Extrahiere Event-Typ
const eventType = webhookData.event || '';
const eventData = webhookData.data || {};
const timestamp = webhookData.timestamp || new Date().toISOString();

// Bestimme Titel und Inhalt je nach Event-Typ
let title = '';
let content = '';

if (eventType.startsWith('session.')) {
  // Session-Events
  title = eventData.title || `Session ${eventData.id || ''}`;
  content = eventData.transcript || eventData.meeting_minutes || eventData.conversations || '';
  
} else if (eventType === 'highlight.created') {
  // Highlight-Events
  title = eventData.title || 'Highlight';
  content = `${eventData.mainIdea || ''}\n\n${eventData.cleanedQuote || eventData.rawQuote || ''}`;
  
} else if (eventType === 'todo.exported') {
  // Todo-Events
  title = `Todo: ${eventData.text || 'Unnamed'}`;
  content = `**Text:** ${eventData.text || ''}\n**Due Date:** ${eventData.dueDate || 'N/A'}\n**Session ID:** ${eventData.sessionId || ''}`;
  
} else {
  // Unbekanntes Event
  title = `Unknown Event: ${eventType}`;
  content = JSON.stringify(eventData, null, 2);
}

return {
  json: {
    eventType: eventType,
    title: title,
    content: content,
    timestamp: timestamp,
    rawData: webhookData
  }
};
```

---

## 🎯 Nächste Schritte

1. **Workflow anpassen:**
   - Code-Node hinzufügen für Parsing
   - Notion-Node anpassen: `$json.title` und `$json.content` verwenden

2. **Testen:**
   - Mit verschiedenen Event-Typen testen
   - Prüfen ob alle Formate korrekt verarbeitet werden

3. **Optional:**
   - Filter-Node hinzufügen, um nur bestimmte Event-Typen zu verarbeiten
   - Fehlerbehandlung für unbekannte Event-Typen

