# 🔧 Notion Properties manuell eintragen

## Problem

"Error fetching options from Notion" → n8n kann die Database nicht abrufen.

**Lösung:** Properties **manuell** mit exakten Namen eintragen!

---

## Exakte Property-Namen (aus Prompt)

Die Properties müssen **exakt** so heißen wie in Notion:

1. **Titel** (nicht "Title"!)
2. **Event-Typ** (mit Bindestrich!)
3. **Status**
4. **Zusammenfassung** (AI Summary - wird automatisch generiert, nicht mappen!)
5. **Transkript**
6. **Session ID** (mit Leerzeichen!)
7. **Session Titel** (mit Leerzeichen!)
8. **Erstellungsdatum**
9. **Due Date** (mit Leerzeichen!)

---

## Manuelle Konfiguration im Notion-Node

### Schritt 1: Database ID prüfen

**Im Notion-Node:**
- Database: **"By ID"** auswählen
- Database ID: `DEINE_DATABASE_ID` eintragen
- Format: `2ca31cc6-fd56-8079-8a58-d74ec1097a36` oder `2ca31cc6fd5680798a58d74ec1097a36`

### Schritt 2: Properties manuell eintragen

**Für jedes Property:**

1. **"Add property"** klicken
2. **"Key Name or ID"** Feld: **Exakten Namen eintragen** (nicht aus Liste wählen!)
3. **Expression** eintragen

---

## Property-Mappings (exakt!)

### Property 1: Titel
```
Key Name or ID: Titel|title
Title: {{ $json.title }}
```

### Property 2: Event-Typ
```
Key Name or ID: Event-Typ|select
Option Name or ID: {{ $json.eventType }}
```

### Property 3: Status
```
Key Name or ID: Status|select
Option Name or ID: {{ $json.status || '' }}
```

### Property 4: Transkript
```
Key Name or ID: Transkript|rich_text
Text Content: {{ $json.content }}
```

### Property 5: Session ID
```
Key Name or ID: Session ID|text
Text Value: {{ $json.sessionId }}
```

### Property 6: Session Titel
```
Key Name or ID: Session Titel|text
Text Value: {{ $json.sessionTitle }}
```

### Property 7: Erstellungsdatum
```
Key Name or ID: Erstellungsdatum|date
Date Value: {{ $json.timestamp }}
```

### Property 8: Due Date
```
Key Name or ID: Due Date|date
Date Value: {{ $json.dueDate || '' }}
```

**WICHTIG:** "Zusammenfassung" NICHT mappen - wird automatisch von Notion AI generiert!

---

## Format: Property-Name|Property-Type

**Format:** `Property-Name|Property-Type`

**Beispiele:**
- `Titel|title`
- `Event-Typ|select`
- `Status|select`
- `Transkript|rich_text`
- `Session ID|text`
- `Session Titel|text`
- `Erstellungsdatum|date`
- `Due Date|date`

**Wichtig:** 
- Property-Name muss **exakt** mit Notion übereinstimmen
- Property-Type muss korrekt sein (`title`, `select`, `rich_text`, `text`, `date`)

---

## Häufige Fehler

### Fehler 1: Falscher Property-Name
```
❌ "Title" statt "Titel"
❌ "Event Typ" statt "Event-Typ"
❌ "SessionID" statt "Session ID"
```

### Fehler 2: Falscher Property-Type
```
❌ "Titel|text" statt "Titel|title"
❌ "Transkript|text" statt "Transkript|rich_text"
```

### Fehler 3: Database ID falsch
```
❌ Database nicht "By ID" ausgewählt
❌ Database ID falsch kopiert
```

---

## Prüfen: Property-Namen in Notion

**In Notion:**
1. Database öffnen
2. Spalten-Header prüfen
3. **Exakte Namen** notieren (inkl. Leerzeichen, Bindestriche, Groß-/Kleinschreibung)

**Beispiel:**
- Wenn Spalte heißt: "Session ID" → n8n: `Session ID|text`
- Wenn Spalte heißt: "Event-Typ" → n8n: `Event-Typ|select`
- Wenn Spalte heißt: "Due Date" → n8n: `Due Date|date`

---

## Quick Copy: Alle Properties auf einmal

**Für manuelles Eintragen:**

```
Titel|title → Title: {{ $json.title }}
Event-Typ|select → Option: {{ $json.eventType }}
Status|select → Option: {{ $json.status || '' }}
Transkript|rich_text → Text: {{ $json.content }}
Session ID|text → Text: {{ $json.sessionId }}
Session Titel|text → Text: {{ $json.sessionTitle }}
Erstellungsdatum|date → Date: {{ $json.timestamp }}
Due Date|date → Date: {{ $json.dueDate || '' }}
```

---

## Checkliste

- [ ] Database ID korrekt eingetragen (By ID)?
- [ ] Property-Namen exakt wie in Notion?
- [ ] Property-Types korrekt (`|title`, `|select`, etc.)?
- [ ] Expressions korrekt (`{{ $json.xxx }}`)?
- [ ] "Zusammenfassung" NICHT gemappt (wird automatisch generiert)?
- [ ] Test-Webhook gesendet?

