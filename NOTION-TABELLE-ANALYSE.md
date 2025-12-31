# 📊 Notion-Tabellen-Analyse: Hedy Webhook to Notion

## Aktuelle Situation

### Notion-Tabelle hat:
1. **Titel** ✅ - wird befüllt
2. **Zusammenfassung** ❌ - bleibt leer
3. **Transkript** ✅ - wird befüllt
4. **Erstellungsdatum** ⚠️ - wird nicht explizit gesetzt (Notion setzt automatisch)

### Workflow schreibt aktuell:
- `Titel` → `$json.title`
- `Transkript` → `$json.content`
- `Zusammenfassung` → nicht befüllt
- `Erstellungsdatum` → nicht gesetzt

---

## Probleme

### 1. **"Zusammenfassung" bleibt leer**
- Die Spalte existiert, wird aber nie befüllt
- Verschwendeter Platz in der Tabelle
- Keine Nutzung der vorhandenen Struktur

### 2. **Keine Unterscheidung nach Event-Typ**
- Alle Events (Sessions, Highlights, Todos) landen in derselben Tabelle
- Schwer zu filtern/sortieren nach Event-Typ
- Keine Möglichkeit, nur Todos oder nur Highlights zu sehen

### 3. **Erstellungsdatum nicht genutzt**
- Workflow hat `timestamp` verfügbar, nutzt es aber nicht
- Notion setzt automatisch das aktuelle Datum
- Original-Timestamp von Hedy geht verloren

### 4. **Inhalt nicht optimal strukturiert**
- Bei Todos: Alle Infos (Text, Due Date, Session ID) im "Transkript"-Feld
- Bei Highlights: Alle Infos im "Transkript"-Feld
- Bei Sessions: Transkript passt, aber Zusammenfassung könnte `meeting_minutes` enthalten

---

## Verbesserungsvorschläge

### Option 1: Aktuelle Struktur optimieren (minimaler Aufwand)

**Spalten befüllen:**
- **Titel** → Event-Typ + relevante Info (z.B. "Todo: Finalize proposal")
- **Zusammenfassung** → 
  - Bei Todos: `dueDate` oder leer
  - Bei Highlights: `mainIdea`
  - Bei Sessions: `meeting_minutes` (falls vorhanden)
- **Transkript** → Hauptinhalt (wie bisher)
- **Erstellungsdatum** → `timestamp` aus Webhook setzen

**Vorteile:**
- Keine Änderung der Tabellenstruktur nötig
- Schnell umsetzbar
- Nutzt vorhandene Spalten

**Nachteile:**
- "Zusammenfassung" wird unterschiedlich genutzt
- Keine saubere Trennung nach Event-Typ

---

### Option 2: Event-Typ als separate Spalte (empfohlen)

**Neue Struktur:**
1. **Titel** → Name/Text des Events
2. **Event-Typ** → `session.created`, `highlight.created`, `todo.exported` (Select/Multi-select)
3. **Zusammenfassung** → 
  - Bei Todos: `dueDate`
  - Bei Highlights: `mainIdea`
  - Bei Sessions: `meeting_minutes`
4. **Transkript** → Vollständiger Inhalt
5. **Erstellungsdatum** → `timestamp` aus Webhook

**Vorteile:**
- Klare Filterung nach Event-Typ möglich
- Strukturierte Daten
- Professioneller Aufbau

**Nachteile:**
- Notion-Tabelle muss angepasst werden (neue Spalte)

---

### Option 3: Separate Tabellen pro Event-Typ (maximaler Aufwand)

**Struktur:**
- **Tabelle 1:** Sessions
  - Titel, Transkript, Meeting Minutes, Start/Ende, Dauer
- **Tabelle 2:** Highlights  
  - Titel, Hauptidee, Zitat, AI Insight, Session ID
- **Tabelle 3:** Todos
  - Text, Due Date, Session ID, Status

**Vorteile:**
- Optimal strukturiert für jeden Event-Typ
- Keine Vermischung unterschiedlicher Datentypen
- Beste Performance bei großen Datenmengen

**Nachteile:**
- Mehr Aufwand (3 Tabellen, 3 Workflows oder komplexer Routing)
- Mehr Wartung

---

## Empfehlung: Option 2

### Notion-Tabelle anpassen:

**Spalten:**
1. **Titel** (Title) - Name des Events
2. **Event-Typ** (Select) - `session.created`, `session.ended`, `highlight.created`, `todo.exported`
3. **Zusammenfassung** (Rich Text) - Kurze Zusammenfassung je nach Typ
4. **Transkript** (Rich Text) - Vollständiger Inhalt
5. **Erstellungsdatum** (Date) - Timestamp vom Webhook
6. **Session ID** (Text, optional) - Für Verknüpfung zwischen Events

### Workflow anpassen:

```javascript
// Im Parse-Node zusätzlich ausgeben:
return {
  json: {
    eventType: eventType,
    title: title,
    summary: summary,  // NEU: Für Zusammenfassung
    content: content,
    timestamp: timestamp,
    sessionId: eventData.sessionId || null  // NEU: Für Session-Verknüpfung
  }
};
```

**Notion-Node Properties:**
- `Titel` → `$json.title`
- `Event-Typ` → `$json.eventType`
- `Zusammenfassung` → `$json.summary`
- `Transkript` → `$json.content`
- `Erstellungsdatum` → `$json.timestamp`
- `Session ID` → `$json.sessionId` (optional)

---

## Schnelllösung (ohne Tabellenänderung)

Falls du die Tabelle nicht ändern möchtest, kannst du:

1. **Zusammenfassung befüllen:**
   - Bei Todos: `dueDate`
   - Bei Highlights: `mainIdea`
   - Bei Sessions: `meeting_minutes`

2. **Erstellungsdatum setzen:**
   - Nutze `timestamp` aus dem Webhook

3. **Titel erweitern:**
   - Füge Event-Typ hinzu: `[Todo] Finalize proposal` oder `[Highlight] Key Decision`

---

## Beispiel: Optimierter Code

```javascript
// Bestimme Zusammenfassung je nach Event-Typ
let summary = '';

if (eventType.startsWith('session.')) {
  summary = eventData.meeting_minutes || eventData.title || '';
} else if (eventType === 'highlight.created') {
  summary = eventData.mainIdea || eventData.title || '';
} else if (eventType === 'todo.exported') {
  summary = eventData.dueDate || '';
}

return {
  json: {
    eventType: eventType,
    title: title,
    summary: summary,  // Für Zusammenfassung-Spalte
    content: content,
    timestamp: timestamp,
    sessionId: eventData.sessionId || null
  }
};
```

