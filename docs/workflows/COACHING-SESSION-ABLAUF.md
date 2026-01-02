# 💬 Coaching-Session Ablauf mit Kontext-Transkripten

## Szenario

1. **Mehrere YouTube-Videos transkribiert** → Transkripte in Notion
2. **Coaching in Hedy starten** → Mit Kontext aus Notion-Transkripten
3. **Frage:** Landet die Coaching-Session automatisch in Notion?

---

## ✅ Antwort: Ja, automatisch!

### Was passiert:

1. **Du startest Coaching-Session in Hedy**
   - Verwendest Transkripte aus Notion als Kontext
   - Hedy erstellt neue Session

2. **Hedy sendet Webhook-Events:**
   - `session.created` → Session gestartet
   - `session.ended` → Session beendet (mit Transkript)
   - `highlight.created` → Wichtige Punkte erkannt
   - `todo.exported` → Todos erstellt

3. **Unser Workflow empfängt automatisch:**
   - Alle Events werden verarbeitet
   - Daten werden strukturiert
   - Landen automatisch in Notion

---

## Detaillierter Ablauf

### Schritt 1: Coaching-Session starten

```
Du in Hedy:
┌─────────────────────────────────┐
│ Coaching-Session starten        │
│ Kontext: Transkripte aus Notion  │
│ (z.B. mehrere n8n-Tutorials)    │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Hedy erstellt Session            │
│ - Session ID generiert           │
│ - Kontext geladen                │
│ - Transkription startet          │
└────────────┬────────────────────┘
             │
             │ Webhook Event: session.created
             ▼
┌─────────────────────────────────┐
│ n8n Workflow empfängt            │
│ → Speichert in Notion            │
│   - Titel: Session Name          │
│   - Event-Typ: session.created  │
│   - Transkript: (noch leer)      │
└─────────────────────────────────┘
```

### Schritt 2: Coaching durchführen

```
Du in Hedy:
┌─────────────────────────────────┐
│ Coaching-Gespräch               │
│ - Fragen stellen                │
│ - Antworten erhalten            │
│ - Kontext wird verwendet        │
└────────────┬────────────────────┘
             │
             │ Während des Gesprächs:
             ▼
┌─────────────────────────────────┐
│ Hedy erkennt Highlights          │
│ → Webhook Event: highlight.created│
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ n8n Workflow empfängt            │
│ → Speichert Highlight in Notion │
│   - Titel: Highlight-Titel      │
│   - Event-Typ: highlight.created│
│   - Session ID: verknüpft       │
└─────────────────────────────────┘
```

### Schritt 3: Todos erstellen

```
Du in Hedy:
┌─────────────────────────────────┐
│ Coaching erstellt Todos          │
│ → Webhook Event: todo.exported  │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ n8n Workflow empfängt            │
│ → Speichert Todo in Notion       │
│   - Titel: Todo-Text            │
│   - Event-Typ: todo.exported    │
│   - Status: offen                │
│   - Session ID: verknüpft       │
└─────────────────────────────────┘
```

### Schritt 4: Session beenden

```
Du in Hedy:
┌─────────────────────────────────┐
│ Coaching-Session beenden         │
└────────────┬────────────────────┘
             │
             │ Webhook Event: session.ended
             ▼
┌─────────────────────────────────┐
│ Hedy sendet vollständiges        │
│ Transkript der Session           │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ n8n Workflow empfängt            │
│ → Speichert in Notion            │
│   - Titel: Session Name          │
│   - Event-Typ: session.ended    │
│   - Transkript: Vollständig     │
│   - Zusammenfassung: AI-generiert│
└─────────────────────────────────┘
```

---

## Ergebnis in Notion

### Alle Events einer Coaching-Session:

1. **Session Event (session.created)**
   - Titel: "Coaching Session - n8n Fortbildung"
   - Event-Typ: `session.created`
   - Transkript: (noch leer beim Start)

2. **Highlights (highlight.created)**
   - Titel: "Wichtige n8n-Neuerung"
   - Event-Typ: `highlight.created`
   - Session ID: verknüpft zur Session
   - Hauptidee: AI-generierte Zusammenfassung

3. **Todos (todo.exported)**
   - Titel: "Workflow X testen"
   - Event-Typ: `todo.exported`
   - Status: offen
   - Session ID: verknüpft zur Session

4. **Session Event (session.ended)**
   - Titel: "Coaching Session - n8n Fortbildung"
   - Event-Typ: `session.ended`
   - Transkript: Vollständiges Gespräch
   - Zusammenfassung: AI-generiert von Notion

---

## Verknüpfung durch Session ID

**Wichtig:** Alle Events haben die gleiche `Session ID`!

**In Notion kannst du:**
- View "Nach Session gruppiert" verwenden
- Alle Events einer Coaching-Session zusammen sehen:
  - Session Start/Ende
  - Alle Highlights
  - Alle Todos

**Beispiel:**
```
Session: "Coaching - n8n Fortbildung"
├── session.created (Start)
├── highlight.created (Neuerung 1)
├── highlight.created (Neuerung 2)
├── todo.exported (Workflow testen)
└── session.ended (Ende mit Transkript)
```

---

## Kontext-Verwendung

### Wie verwendest du die Transkripte als Kontext?

**Option 1: Manuell in Hedy**
- Transkripte aus Notion kopieren
- In Hedy als Kontext einfügen
- Coaching starten

**Option 2: Automatisch (falls Hedy API unterstützt)**
- Hedy API könnte Kontext aus Notion lesen
- Oder du kopierst Transkripte vorher

**Wichtig:** Der Kontext wird nicht im Webhook mitgesendet, nur das Ergebnis der Coaching-Session!

---

## Workflow-Verhalten

### Unser Workflow behandelt alle Events gleich:

✅ **session.created** → Wird gespeichert
✅ **session.ended** → Wird gespeichert (mit vollständigem Transkript)
✅ **highlight.created** → Wird gespeichert
✅ **todo.exported** → Wird gespeichert

**Keine Unterscheidung zwischen:**
- YouTube-Transkription-Sessions
- Coaching-Sessions
- Anderen Session-Typen

**Alle landen automatisch in Notion!**

---

## Beispiel: Kompletter Zyklus

### Tag 1: YouTube-Videos transkribieren
```
1. YouTube-Link in Hedy → Transkription
2. session.ended → Notion (Transkript Video 1)
3. YouTube-Link in Hedy → Transkription
4. session.ended → Notion (Transkript Video 2)
```

### Tag 2: Coaching mit Kontext
```
1. Coaching starten (Kontext: Video 1 + Video 2)
2. session.created → Notion
3. Während Coaching:
   - highlight.created → Notion
   - todo.exported → Notion
4. Coaching beenden
5. session.ended → Notion (Vollständiges Coaching-Transkript)
```

### Ergebnis in Notion:
- **3 Sessions:** Video 1, Video 2, Coaching
- **Mehrere Highlights:** Aus Coaching
- **Mehrere Todos:** Aus Coaching
- **Alle verknüpft:** Durch Session ID (bei Highlights/Todos)

---

## Fazit

✅ **Ja, Coaching-Sessions landen automatisch in Notion!**

- Unabhängig davon, ob Kontext verwendet wird
- Alle Events werden automatisch empfangen
- Strukturiert gespeichert mit AI-Zusammenfassungen
- Verknüpft durch Session ID

**Der Workflow funktioniert für:**
- YouTube-Transkriptionen
- Coaching-Sessions
- Jede andere Hedy-Session

**Keine zusätzliche Konfiguration nötig!**

