# 📊 Option 2: Optimale Struktur für Hedy Events in Notion

## Tabellen-Struktur

### Spalten-Übersicht

| Spalte | Typ | Beschreibung | Verwendung |
|--------|-----|--------------|------------|
| **Titel** | Title | Name/Text des Events | Primärschlüssel, Suchfeld |
| **Event-Typ** | Select | Art des Events | Filterung, Gruppierung |
| **Status** | Select | Status (optional) | Für Todos: offen/erledigt |
| **Zusammenfassung** | Rich Text | Kurze Zusammenfassung | Quick-View, Vorschau |
| **Transkript** | Rich Text | Vollständiger Inhalt | Detailansicht |
| **Session ID** | Text | Verknüpfung zur Session | Verknüpfung zwischen Events |
| **Session Titel** | Text | Name der Session | Kontext ohne Verknüpfung |
| **Erstellungsdatum** | Date | Timestamp vom Webhook | Sortierung, Zeitfilter |
| **Due Date** | Date | Fälligkeitsdatum (nur Todos) | Todo-Management |
| **Tags** | Multi-select | Kategorien/Themen | Flexible Kategorisierung |

---

## Detaillierte Spalten-Definitionen

### 1. **Titel** (Title)
- **Typ:** Title
- **Verwendung:** 
  - Sessions: `"Weekly Team Sync"`
  - Highlights: `"Key Decision on Mobile App"`
  - Todos: `"Finalize the project proposal"`
- **Format:** Event-spezifisch, aber konsistent

### 2. **Event-Typ** (Select)
- **Typ:** Select
- **Optionen:**
  - `session.created` - Neue Session gestartet
  - `session.ended` - Session beendet
  - `highlight.created` - Highlight erstellt
  - `todo.exported` - Todo exportiert
- **Farbe-Codierung:**
  - Sessions: 🔵 Blau
  - Highlights: 🟡 Gelb
  - Todos: 🟢 Grün

### 3. **Status** (Select, optional)
- **Typ:** Select
- **Optionen:**
  - `offen` (nur für Todos)
  - `erledigt` (nur für Todos)
  - `-` (für Sessions/Highlights)
- **Verwendung:** Todo-Management

### 4. **Zusammenfassung** (Rich Text)
- **Typ:** Rich Text
- **Inhalt je Event-Typ:**
  - **Sessions:** `meeting_minutes` (falls vorhanden) oder `title`
  - **Highlights:** `mainIdea` oder `title`
  - **Todos:** `dueDate` oder leer
- **Zweck:** Quick-View ohne Details öffnen zu müssen

### 5. **Transkript** (Rich Text)
- **Typ:** Rich Text
- **Inhalt je Event-Typ:**
  - **Sessions:** `transcript` oder `conversations` oder `meeting_minutes`
  - **Highlights:** Formatierte Darstellung mit `mainIdea`, `cleanedQuote`, `aiInsight`
  - **Todos:** Formatierte Darstellung mit `text`, `dueDate`, `sessionId`
- **Zweck:** Vollständige Informationen

### 6. **Session ID** (Text)
- **Typ:** Text
- **Verwendung:** 
  - Verknüpfung zwischen Events derselben Session
  - Filterung: "Alle Events dieser Session"
  - Optional: Relation zu separater Sessions-Tabelle

### 7. **Session Titel** (Text)
- **Typ:** Text
- **Verwendung:**
  - Kontext ohne Verknüpfung
  - Schnelle Identifikation der zugehörigen Session
  - Wird nur bei Highlights und Todos befüllt

### 8. **Erstellungsdatum** (Date)
- **Typ:** Date
- **Quelle:** `timestamp` aus Webhook
- **Verwendung:** 
  - Chronologische Sortierung
  - Zeitbasierte Filterung
  - "Letzte 7 Tage", "Dieser Monat"

### 9. **Due Date** (Date, optional)
- **Typ:** Date
- **Verwendung:** 
  - Nur für Todos relevant
  - Todo-Management: "Fällig heute", "Überfällig"
  - Leer für Sessions/Highlights

### 10. **Tags** (Multi-select, optional)
- **Typ:** Multi-select
- **Verwendung:**
  - Flexible Kategorisierung
  - Themen, Projekte, Teams
  - Kann später manuell oder automatisch befüllt werden

---

## Notion-Views (Ansichten)

### View 1: **Alle Events** (Standard)
- **Zweck:** Übersicht aller Events
- **Spalten:** Titel, Event-Typ, Zusammenfassung, Erstellungsdatum
- **Sortierung:** Erstellungsdatum (neueste zuerst)
- **Filter:** Keine
- **Gruppierung:** Keine

### View 2: **Nur Todos**
- **Zweck:** Todo-Management
- **Spalten:** Titel, Status, Due Date, Zusammenfassung, Session Titel
- **Sortierung:** Due Date (nächste zuerst)
- **Filter:** `Event-Typ` = `todo.exported`
- **Gruppierung:** Nach Status (offen/erledigt)

### View 3: **Nur Highlights**
- **Zweck:** Wichtige Entscheidungen und Insights
- **Spalten:** Titel, Zusammenfassung, Transkript, Session Titel, Erstellungsdatum
- **Sortierung:** Erstellungsdatum (neueste zuerst)
- **Filter:** `Event-Typ` = `highlight.created`
- **Gruppierung:** Nach Session Titel

### View 4: **Nur Sessions**
- **Zweck:** Meeting-Übersicht
- **Spalten:** Titel, Zusammenfassung, Transkript, Erstellungsdatum
- **Sortierung:** Erstellungsdatum (neueste zuerst)
- **Filter:** `Event-Typ` beginnt mit `session.`
- **Gruppierung:** Nach Datum (Woche/Monat)

### View 5: **Nach Session gruppiert**
- **Zweck:** Alle Events einer Session zusammen sehen
- **Spalten:** Titel, Event-Typ, Zusammenfassung, Transkript, Erstellungsdatum
- **Sortierung:** Erstellungsdatum (innerhalb der Gruppe)
- **Filter:** Keine
- **Gruppierung:** Nach Session ID oder Session Titel

### View 6: **Fällige Todos**
- **Zweck:** Todo-Management mit Fokus auf Fälligkeit
- **Spalten:** Titel, Due Date, Status, Zusammenfassung, Session Titel
- **Sortierung:** Due Date (nächste zuerst)
- **Filter:** 
  - `Event-Typ` = `todo.exported`
  - `Status` = `offen` (oder leer)
  - `Due Date` ist nicht leer
- **Gruppierung:** Nach Due Date (Heute, Diese Woche, Später)

### View 7: **Zeitliche Übersicht**
- **Zweck:** Chronologische Darstellung
- **Spalten:** Erstellungsdatum, Titel, Event-Typ, Zusammenfassung
- **Sortierung:** Erstellungsdatum (neueste zuerst)
- **Filter:** Erstellungsdatum = letzte 30 Tage
- **Gruppierung:** Nach Datum (Tag)

### View 8: **Kanban-Board (Todos)**
- **Zweck:** Visuelles Todo-Management
- **Typ:** Board-View
- **Spalten:** Status (offen, erledigt)
- **Karten:** Titel, Due Date, Zusammenfassung
- **Filter:** `Event-Typ` = `todo.exported`

---

## Workflow-Anpassungen

### Erweiterter Parse-Code

```javascript
// Parse Hedy Webhook-Daten und normalisiere für Notion
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
  // Session-Events
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
  // Session-Titel müsste aus einer vorherigen Session gelesen werden
  // Oder aus dem Webhook, falls verfügbar
  
} else if (eventType === 'todo.exported') {
  // Todo-Events
  title = eventData.text || 'Unnamed Todo';
  summary = eventData.dueDate || '';
  status = 'offen'; // Standard-Status
  
  const parts = [];
  parts.push(`**Text:** ${eventData.text || ''}`);
  if (eventData.dueDate) {
    parts.push(`**Fälligkeitsdatum:** ${eventData.dueDate}`);
    // Versuche Due Date zu parsen (falls Format bekannt)
    // dueDate = parseDueDate(eventData.dueDate);
  }
  if (eventData.sessionId) parts.push(`**Session ID:** ${eventData.sessionId}`);
  if (eventData.id) parts.push(`**Todo ID:** ${eventData.id}`);
  content = parts.join('\n');
  
  sessionId = eventData.sessionId || null;
  // Due Date parsen (falls Format bekannt)
  // dueDate = parseDueDate(eventData.dueDate);
  
} else {
  // Unbekanntes Event
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
    sessionId: sessionId,
    sessionTitle: sessionTitle,
    dueDate: dueDate,
    status: status,
    rawData: webhookData
  }
};
```

### Notion-Node Properties

```json
{
  "propertiesUi": {
    "propertyValues": [
      {
        "key": "Titel|title",
        "title": "={{ $json.title }}"
      },
      {
        "key": "Event-Typ|select",
        "selectValue": "={{ $json.eventType }}"
      },
      {
        "key": "Status|select",
        "selectValue": "={{ $json.status || '' }}"
      },
      {
        "key": "Zusammenfassung|rich_text",
        "textContent": "={{ $json.summary }}"
      },
      {
        "key": "Transkript|rich_text",
        "textContent": "={{ $json.content }}"
      },
      {
        "key": "Session ID|text",
        "textValue": "={{ $json.sessionId || '' }}"
      },
      {
        "key": "Session Titel|text",
        "textValue": "={{ $json.sessionTitle || '' }}"
      },
      {
        "key": "Erstellungsdatum|date",
        "dateValue": "={{ $json.timestamp }}"
      },
      {
        "key": "Due Date|date",
        "dateValue": "={{ $json.dueDate || '' }}"
      }
    ]
  }
}
```

---

## Erweiterte Features (Optional)

### 1. **Relation zu Sessions-Tabelle**
- Erstelle separate "Sessions"-Tabelle
- Relation von Events zu Sessions
- Vorteil: Zwei-Wege-Verknüpfung, bessere Performance

### 2. **Automatische Tags**
- Basierend auf Session-Titel
- Basierend auf Keywords im Content
- Basierend auf Event-Typ

### 3. **Template für verschiedene Event-Typen**
- Notion-Templates für jeden Event-Typ
- Automatische Formatierung
- Konsistente Darstellung

### 4. **Rollup-Felder**
- Anzahl Todos pro Session
- Anzahl Highlights pro Session
- Durchschnittliche Session-Dauer

---

## Setup-Anleitung

### Schritt 1: Notion-Tabelle erstellen

1. Erstelle neue Datenbank in Notion
2. Füge folgende Spalten hinzu:
   - Titel (Title) - bereits vorhanden
   - Event-Typ (Select) - Optionen hinzufügen
   - Status (Select) - Optionen: `offen`, `erledigt`, `-`
   - Zusammenfassung (Text)
   - Transkript (Text)
   - Session ID (Text)
   - Session Titel (Text)
   - Erstellungsdatum (Date)
   - Due Date (Date)

### Schritt 2: Views erstellen

1. **Alle Events** - Standard-View
2. **Nur Todos** - Filter: Event-Typ = todo.exported
3. **Nur Highlights** - Filter: Event-Typ = highlight.created
4. **Nur Sessions** - Filter: Event-Typ beginnt mit "session."
5. **Nach Session gruppiert** - Gruppierung: Session ID
6. **Fällige Todos** - Filter: Event-Typ = todo.exported, Status = offen
7. **Zeitliche Übersicht** - Gruppierung: Erstellungsdatum (Tag)
8. **Kanban-Board** - Board-View, Gruppierung: Status

### Schritt 3: Workflow anpassen

1. Parse-Node erweitern (siehe Code oben)
2. Notion-Node Properties anpassen
3. Testen mit verschiedenen Event-Typen

---

## Beispiel-Daten

### Session Event
```
Titel: "Weekly Team Sync"
Event-Typ: session.ended
Zusammenfassung: "1. Project Status\n2. Next Steps\n3. Blockers"
Transkript: "John: Let's review our progress..."
Session ID: "sess_123456789"
Erstellungsdatum: 2024-03-15T15:15:00Z
```

### Highlight Event
```
Titel: "Key Decision on Mobile App"
Event-Typ: highlight.created
Zusammenfassung: "Team agreed to prioritize mobile app development"
Transkript: "**Hauptidee:** ...\n**Zitat:** ...\n**AI Insight:** ..."
Session ID: "sess_123456789"
Session Titel: "Weekly Team Sync"
Erstellungsdatum: 2024-03-15T14:35:00Z
```

### Todo Event
```
Titel: "Finalize the project proposal"
Event-Typ: todo.exported
Status: offen
Zusammenfassung: "May 18, 2027 3pm"
Transkript: "**Text:** Finalize...\n**Fälligkeitsdatum:** May 18, 2027 3pm"
Session ID: "sess_123456789"
Session Titel: "Weekly Team Sync"
Due Date: 2027-05-18
Erstellungsdatum: 2024-03-15T14:30:00Z
```

