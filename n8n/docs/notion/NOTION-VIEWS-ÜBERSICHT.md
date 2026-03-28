# 📋 Notion-Views Übersicht für Hedy Events

## View-Konfigurationen im Detail

### View 1: **Alle Events** (Standard-View)
**Zweck:** Zentrale Übersicht aller Events

**Spalten:**
- ✅ Titel (sichtbar)
- ✅ Event-Typ (sichtbar, mit Farb-Codierung)
- ✅ Zusammenfassung (sichtbar, gekürzt)
- ✅ Erstellungsdatum (sichtbar)
- ⚪ Transkript (versteckt)
- ⚪ Session ID (versteckt)
- ⚪ Session Titel (versteckt)
- ⚪ Due Date (versteckt)
- ⚪ Status (versteckt)

**Sortierung:**
- Erstellungsdatum: Neueste zuerst

**Filter:**
- Keine

**Gruppierung:**
- Keine

**Icon:** 📊

---

### View 2: **Nur Todos**
**Zweck:** Fokussiertes Todo-Management

**Spalten:**
- ✅ Titel (sichtbar)
- ✅ Status (sichtbar, mit Farb-Codierung)
- ✅ Due Date (sichtbar)
- ✅ Zusammenfassung (sichtbar)
- ✅ Session Titel (sichtbar)
- ⚪ Event-Typ (versteckt, aber gefiltert)
- ⚪ Transkript (versteckt)
- ⚪ Session ID (versteckt)
- ⚪ Erstellungsdatum (versteckt)

**Sortierung:**
- Due Date: Nächste zuerst
- Falls Due Date leer: Erstellungsdatum (neueste zuerst)

**Filter:**
- Event-Typ = `todo.exported`

**Gruppierung:**
- Nach Status (offen / erledigt)

**Icon:** ✅

**Zusätzliche Features:**
- Farb-Codierung nach Fälligkeit:
  - 🔴 Rot: Überfällig
  - 🟡 Gelb: Fällig heute/diese Woche
  - 🟢 Grün: Später

---

### View 3: **Nur Highlights**
**Zweck:** Wichtige Entscheidungen und Insights im Fokus

**Spalten:**
- ✅ Titel (sichtbar)
- ✅ Zusammenfassung (sichtbar, erweitert)
- ✅ Transkript (sichtbar, gekürzt)
- ✅ Session Titel (sichtbar)
- ✅ Erstellungsdatum (sichtbar)
- ⚪ Event-Typ (versteckt, aber gefiltert)
- ⚪ Session ID (versteckt)
- ⚪ Due Date (versteckt)
- ⚪ Status (versteckt)

**Sortierung:**
- Erstellungsdatum: Neueste zuerst

**Filter:**
- Event-Typ = `highlight.created`

**Gruppierung:**
- Nach Session Titel

**Icon:** 💡

**Zusätzliche Features:**
- Highlight-Symbole: ⭐ für wichtige Highlights
- Zusammenfassung zeigt `mainIdea` prominent

---

### View 4: **Nur Sessions**
**Zweck:** Meeting-Übersicht und Transkripte

**Spalten:**
- ✅ Titel (sichtbar)
- ✅ Zusammenfassung (sichtbar, zeigt `meeting_minutes`)
- ✅ Transkript (sichtbar, erweitert)
- ✅ Erstellungsdatum (sichtbar)
- ⚪ Event-Typ (versteckt, aber gefiltert)
- ⚪ Session ID (versteckt)
- ⚪ Session Titel (versteckt)
- ⚪ Due Date (versteckt)
- ⚪ Status (versteckt)

**Sortierung:**
- Erstellungsdatum: Neueste zuerst

**Filter:**
- Event-Typ beginnt mit `session.`

**Gruppierung:**
- Nach Datum (Woche)

**Icon:** 🎤

**Zusätzliche Features:**
- Transkript-Vorschau in der Liste
- Quick-Action: Transkript öffnen

---

### View 5: **Nach Session gruppiert**
**Zweck:** Alle Events einer Session zusammen sehen

**Spalten:**
- ✅ Session Titel (sichtbar, als Gruppen-Header)
- ✅ Titel (sichtbar)
- ✅ Event-Typ (sichtbar)
- ✅ Zusammenfassung (sichtbar)
- ✅ Transkript (sichtbar, gekürzt)
- ✅ Erstellungsdatum (sichtbar)
- ⚪ Session ID (versteckt)
- ⚪ Due Date (versteckt)
- ⚪ Status (versteckt)

**Sortierung:**
- Innerhalb der Gruppe: Erstellungsdatum (chronologisch)

**Filter:**
- Keine

**Gruppierung:**
- Nach Session ID oder Session Titel
- Sortierung der Gruppen: Neueste Session zuerst

**Icon:** 🔗

**Zusätzliche Features:**
- Zeigt alle Events einer Session zusammen:
  - Session Event (created/ended)
  - Alle Highlights dieser Session
  - Alle Todos dieser Session
- Rollup: Anzahl Highlights/Todos pro Session

---

### View 6: **Fällige Todos**
**Zweck:** Todo-Management mit Fokus auf Fälligkeit

**Spalten:**
- ✅ Titel (sichtbar)
- ✅ Due Date (sichtbar, prominent)
- ✅ Status (sichtbar)
- ✅ Zusammenfassung (sichtbar)
- ✅ Session Titel (sichtbar)
- ⚪ Event-Typ (versteckt, aber gefiltert)
- ⚪ Transkript (versteckt)
- ⚪ Session ID (versteckt)
- ⚪ Erstellungsdatum (versteckt)

**Sortierung:**
- Due Date: Nächste zuerst
- Falls Due Date leer: Erstellungsdatum (neueste zuerst)

**Filter:**
- Event-Typ = `todo.exported`
- Status = `offen` (oder leer)
- Due Date ist nicht leer

**Gruppierung:**
- Nach Due Date:
  - 🔴 Überfällig
  - 🟡 Heute
  - 🟢 Diese Woche
  - 🔵 Nächste Woche
  - ⚪ Später

**Icon:** ⏰

**Zusätzliche Features:**
- Farb-Codierung nach Fälligkeit
- Badge mit Tagen bis Fälligkeit
- Quick-Actions: Als erledigt markieren

---

### View 7: **Zeitliche Übersicht**
**Zweck:** Chronologische Darstellung aller Events

**Spalten:**
- ✅ Erstellungsdatum (sichtbar, als Gruppen-Header)
- ✅ Titel (sichtbar)
- ✅ Event-Typ (sichtbar)
- ✅ Zusammenfassung (sichtbar)
- ⚪ Transkript (versteckt)
- ⚪ Session ID (versteckt)
- ⚪ Session Titel (versteckt)
- ⚪ Due Date (versteckt)
- ⚪ Status (versteckt)

**Sortierung:**
- Innerhalb der Gruppe: Erstellungsdatum (chronologisch)

**Filter:**
- Erstellungsdatum = letzte 30 Tage
- Optional: Nur bestimmte Event-Typen

**Gruppierung:**
- Nach Datum (Tag)
- Sortierung der Gruppen: Neueste zuerst

**Icon:** 📅

**Zusätzliche Features:**
- Timeline-Ansicht möglich
- Zeigt Aktivität über Zeit
- Gut für Wochen-/Monats-Reviews

---

### View 8: **Kanban-Board (Todos)**
**Zweck:** Visuelles Todo-Management

**Typ:** Board-View

**Spalten (Board-Kategorien):**
- 🔴 Überfällig
- 🟡 Offen (fällig diese Woche)
- 🟢 Offen (später)
- ✅ Erledigt

**Karten-Inhalt:**
- Titel (prominent)
- Due Date (falls vorhanden)
- Zusammenfassung (klein)
- Session Titel (klein)

**Filter:**
- Event-Typ = `todo.exported`

**Sortierung:**
- Innerhalb der Spalte: Due Date (nächste zuerst)

**Icon:** 📌

**Zusätzliche Features:**
- Drag & Drop zwischen Spalten
- Farb-Codierung nach Fälligkeit
- Quick-Actions auf Karten

---

## View-Erstellung in Notion

### Schritt-für-Schritt Anleitung

1. **View erstellen:**
   - Klicke auf "Add a view" in der Notion-Datenbank
   - Wähle View-Typ (Table, Board, Timeline, etc.)

2. **Spalten ein/ausblenden:**
   - Klicke auf "..." → "Properties"
   - Aktiviere/deaktiviere Spalten

3. **Filter setzen:**
   - Klicke auf "Filter"
   - Füge Bedingungen hinzu:
     - Event-Typ = bestimmter Wert
     - Erstellungsdatum = Zeitraum
     - Status = bestimmter Wert

4. **Sortierung einstellen:**
   - Klicke auf "Sort"
   - Wähle Spalte und Richtung

5. **Gruppierung einrichten:**
   - Klicke auf "Group"
   - Wähle Gruppierungs-Spalte
   - Optional: Sortierung der Gruppen

6. **View benennen:**
   - Klicke auf View-Namen
   - Gib beschreibenden Namen ein
   - Optional: Icon hinzufügen

---

## Erweiterte View-Ideen

### View 9: **Dashboard**
**Zweck:** Übersicht mit Statistiken

**Features:**
- Rollup-Felder:
  - Anzahl Todos (offen)
  - Anzahl Highlights (letzte 7 Tage)
  - Anzahl Sessions (diesen Monat)
- Grafiken/Charts möglich mit Notion-Integrationen

### View 10: **Suche & Filter**
**Zweck:** Erweiterte Suche

**Features:**
- Volltext-Suche über alle Spalten
- Multi-Filter:
  - Event-Typ (mehrere)
  - Datum-Bereich
  - Session-ID
  - Tags

### View 11: **Kalender-View**
**Zweck:** Zeitliche Darstellung

**Typ:** Calendar-View

**Features:**
- Events nach Erstellungsdatum
- Todos nach Due Date
- Farb-Codierung nach Event-Typ

---

## Best Practices

### 1. **View-Namen klar benennen**
- Beschreibend: "Nur Todos" statt "View 2"
- Mit Icon für schnelle Identifikation

### 2. **Relevante Spalten zeigen**
- Nicht zu viele Spalten (max. 5-7 sichtbar)
- Wichtigste Informationen prominent

### 3. **Filter konsistent**
- Filter sollten logisch sein
- Nicht zu restriktiv (sonst leer)

### 4. **Gruppierung sinnvoll**
- Gruppierung nach häufig genutzten Kriterien
- Nicht zu viele Gruppen (max. 10-15)

### 5. **Sortierung hilfreich**
- Standard-Sortierung: Neueste zuerst
- Ausnahmen: Todos nach Due Date

---

## Workflow-Integration

Der optimierte Workflow (`Hedy Webhook to Notion 0.9 - OPTIMIZED.json`) unterstützt alle diese Views automatisch, da er alle benötigten Felder ausgibt:

- ✅ `eventType` → Event-Typ Spalte
- ✅ `summary` → Zusammenfassung Spalte
- ✅ `content` → Transkript Spalte
- ✅ `sessionId` → Session ID Spalte
- ✅ `sessionTitle` → Session Titel Spalte
- ✅ `timestamp` → Erstellungsdatum Spalte
- ✅ `dueDate` → Due Date Spalte
- ✅ `status` → Status Spalte

Nach dem Import des Workflows müssen nur noch die Views in Notion erstellt werden!

