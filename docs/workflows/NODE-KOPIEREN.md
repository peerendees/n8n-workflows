# 📋 Node per Copy & Paste in n8n einfügen

## Option 1: Kompletten Workflow importieren (Empfohlen)

**Am einfachsten:**

1. **Workflow exportieren:**
   - Öffne `Hedy Webhook to Notion 0.9 - OPTIMIZED.json`
   - Kopiere den kompletten Inhalt

2. **In n8n importieren:**
   - n8n → Workflows → Import from File
   - JSON einfügen oder Datei hochladen
   - Workflow wird komplett importiert

**Vorteil:** Alles ist korrekt konfiguriert

---

## Option 2: Node aus JSON extrahieren

**Falls du nur den Notion-Node kopieren willst:**

### Schritt 1: Node aus JSON extrahieren

Aus `Hedy Webhook to Notion 0.9 - OPTIMIZED.json`:

```json
{
  "parameters": {
    "resource": "databasePage",
    "databaseId": {
      "__rl": true,
      "value": "2ca31cc6-fd56-8079-8a58-d74ec1097a36",
      "mode": "list",
      "cachedResultName": "Hedy Transkripte 0.9",
      "cachedResultUrl": "https://www.notion.so/2ca31cc6fd5680798a58d74ec1097a36"
    },
    "title": "Hedy Transkript",
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
          "key": "Transkript|rich_text",
          "textContent": "={{ $json.content }}"
        },
        {
          "key": "Session ID|text",
          "textValue": "={{ $json.sessionId }}"
        },
        {
          "key": "Session Titel|text",
          "textValue": "={{ $json.sessionTitle }}"
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
    },
    "options": {}
  },
  "type": "n8n-nodes-base.notion",
  "typeVersion": 2.2,
  "position": [416, 0],
  "id": "a82bbbce-23bd-4926-8852-a525f1f28791",
  "name": "Hedy Transkript 0.9",
  "credentials": {
    "notionApi": {
      "id": "KpKj51GJ0big0oYv",
      "name": "API Notion"
    }
  }
}
```

### Schritt 2: In n8n manuell konfigurieren

**Problem:** n8n unterstützt kein direktes Copy & Paste von Nodes.

**Lösung:** Properties manuell hinzufügen:

1. Notion-Node öffnen
2. Properties-Sektion öffnen
3. Für jedes Property:
   - "Add property" klicken
   - Property-Name auswählen
   - Expression einfügen

---

## Option 3: Workflow JSON bearbeiten (Für Fortgeschrittene)

**Direkt im JSON:**

1. Workflow exportieren (als JSON)
2. JSON-Datei öffnen
3. Notion-Node finden (Suche nach `"name": "Hedy Transkript 0.9"`)
4. `propertiesUi.propertyValues` Array ersetzen mit:

```json
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
    "key": "Transkript|rich_text",
    "textContent": "={{ $json.content }}"
  },
  {
    "key": "Session ID|text",
    "textValue": "={{ $json.sessionId }}"
  },
  {
    "key": "Session Titel|text",
    "textValue": "={{ $json.sessionTitle }}"
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
```

5. Workflow wieder importieren

**Vorteil:** Schnell, alle Properties auf einmal
**Nachteil:** Fehleranfällig, JSON muss korrekt sein

---

## Empfehlung: Option 1 (Workflow importieren)

**Am sichersten:**

1. `Hedy Webhook to Notion 0.9 - OPTIMIZED.json` öffnen
2. Kompletten Inhalt kopieren
3. In n8n: Workflows → Import from File
4. JSON einfügen
5. Fertig!

**Dann:**
- Database ID anpassen (falls nötig)
- Credentials prüfen
- Workflow aktivieren

---

## Quick Copy: Properties-Array

**Nur die Properties kopieren (für manuelles Einfügen):**

```json
[
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
    "key": "Transkript|rich_text",
    "textContent": "={{ $json.content }}"
  },
  {
    "key": "Session ID|text",
    "textValue": "={{ $json.sessionId }}"
  },
  {
    "key": "Session Titel|text",
    "textValue": "={{ $json.sessionTitle }}"
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
```

**Verwendung:** Als Referenz beim manuellen Konfigurieren in n8n.

