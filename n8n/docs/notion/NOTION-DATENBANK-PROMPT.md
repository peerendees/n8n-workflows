# 📝 Notion-Prompt: Hedy Events Datenbank erstellen

## Prompt für Notion AI

```
Erstelle eine neue Datenbank mit dem Namen "Hedy Events" für die Verwaltung von Meeting-Events, Highlights und Todos aus der Hedy API.

Die Datenbank soll folgende Spalten haben:

1. **Titel** (Title) - Name/Text des Events
   - Dies ist die Hauptspalte für den Namen

2. **Event-Typ** (Select) - Art des Events
   - Optionen:
     - session.created (Blau)
     - session.ended (Blau)
     - highlight.created (Gelb)
     - todo.exported (Grün)

3. **Status** (Select) - Status für Todos
   - Optionen:
     - offen (Gelb)
     - erledigt (Grün)
     - - (Grau, für Sessions/Highlights)

4. **Zusammenfassung** (AI Summary) - Automatische KI-Zusammenfassung
   - Typ: AI Summary (Notion KI generiert automatisch)
   - Basierend auf dem Inhalt der Seite

5. **Transkript** (Text) - Vollständiger Inhalt
   - Typ: Text (Rich Text)
   - Enthält den vollständigen Inhalt des Events

6. **Session ID** (Text) - Verknüpfung zur Session
   - Typ: Text
   - Für Verknüpfung zwischen Events derselben Session

7. **Session Titel** (Text) - Name der Session
   - Typ: Text
   - Kontext ohne Verknüpfung

8. **Erstellungsdatum** (Date) - Timestamp vom Webhook
   - Typ: Date
   - Wird automatisch vom Workflow gesetzt

9. **Due Date** (Date) - Fälligkeitsdatum für Todos
   - Typ: Date
   - Nur für Todos relevant

10. **Tags** (Multi-select, optional) - Flexible Kategorisierung
    - Typ: Multi-select
    - Kann später manuell oder automatisch befüllt werden

Die Datenbank soll verschiedene Views haben:
- Standard-View: Alle Events, sortiert nach Erstellungsdatum (neueste zuerst)
- View "Nur Todos": Gefiltert nach Event-Typ = todo.exported, gruppiert nach Status
- View "Nur Highlights": Gefiltert nach Event-Typ = highlight.created
- View "Nur Sessions": Gefiltert nach Event-Typ beginnt mit "session."
- View "Nach Session gruppiert": Gruppiert nach Session ID
- View "Fällige Todos": Gefiltert nach Event-Typ = todo.exported, Status = offen, Due Date nicht leer, gruppiert nach Due Date
- View "Zeitliche Übersicht": Gruppiert nach Erstellungsdatum (Tag), gefiltert nach letzte 30 Tage
- View "Kanban-Board": Board-View für Todos, gruppiert nach Status

Die Zusammenfassung-Spalte soll automatisch von Notion KI generiert werden basierend auf dem Inhalt der Seite.
```

---

## Alternative: Manuelle Anleitung

Falls Notion AI nicht verfügbar ist, hier die manuelle Anleitung:

### Schritt 1: Neue Datenbank erstellen

1. In Notion: `/` → "Table - Full page" oder "Table - Inline"
2. Name: "Hedy Events"

### Schritt 2: Spalten hinzufügen

**Bereits vorhanden:**
- ✅ Name (Title) - wird automatisch erstellt

**Hinzufügen:**

1. **Event-Typ** (Select)
   - Klicke auf "+" → "Select"
   - Name: "Event-Typ"
   - Optionen hinzufügen:
     - `session.created` (Blau)
     - `session.ended` (Blau)
     - `highlight.created` (Gelb)
     - `todo.exported` (Grün)

2. **Status** (Select)
   - Klicke auf "+" → "Select"
   - Name: "Status"
   - Optionen hinzufügen:
     - `offen` (Gelb)
     - `erledigt` (Grün)
     - `-` (Grau)

3. **Zusammenfassung** (AI Summary)
   - Klicke auf "+" → "AI Summary"
   - Name: "Zusammenfassung"
   - Wird automatisch von Notion KI generiert

4. **Transkript** (Text)
   - Klicke auf "+" → "Text"
   - Name: "Transkript"
   - Typ: Rich Text

5. **Session ID** (Text)
   - Klicke auf "+" → "Text"
   - Name: "Session ID"
   - Typ: Plain Text

6. **Session Titel** (Text)
   - Klicke auf "+" → "Text"
   - Name: "Session Titel"
   - Typ: Plain Text

7. **Erstellungsdatum** (Date)
   - Klicke auf "+" → "Date"
   - Name: "Erstellungsdatum"

8. **Due Date** (Date)
   - Klicke auf "+" → "Date"
   - Name: "Due Date"

9. **Tags** (Multi-select, optional)
   - Klicke auf "+" → "Multi-select"
   - Name: "Tags"
   - Optionen können später hinzugefügt werden

### Schritt 3: Views erstellen

Siehe `NOTION-VIEWS-ÜBERSICHT.md` für detaillierte Anleitung.

---

## Empfehlung: Neu erstellen vs. Ändern

### ✅ **Empfehlung: Neue Datenbank erstellen**

**Warum neu erstellen besser ist:**

1. **AI Summary funktioniert besser bei neuen Einträgen**
   - Notion KI generiert Zusammenfassungen automatisch beim Erstellen
   - Bei bestehenden Einträgen muss manuell "Generate summary" geklickt werden
   - Neue Struktur ist optimiert für AI Summary

2. **Saubere Struktur**
   - Keine Legacy-Daten, die nicht zur neuen Struktur passen
   - Alle Spalten sind korrekt konfiguriert von Anfang an
   - Keine Konflikte mit alten Datenformaten

3. **Einfacher zu testen**
   - Neue Datenbank kann parallel zur alten existieren
   - Workflow kann getestet werden ohne alte Daten zu beeinflussen
   - Bei Problemen einfach zurück zur alten Datenbank

4. **Alte Datenbank als Archiv**
   - Bestehende Daten bleiben unverändert
   - Kann als Referenz/Backup dienen
   - Keine Datenverlust-Risiken

**Nachteile:**
- Alte Daten müssen migriert werden (falls gewünscht)
- Zwei Datenbanken parallel (kann aber auch Vorteil sein)

### ❌ **Nicht empfohlen: Bestehende ändern**

**Warum ändern problematisch ist:**

1. **AI Summary muss manuell generiert werden**
   - Für jeden bestehenden Eintrag einzeln "Generate summary" klicken
   - Sehr zeitaufwändig bei vielen Einträgen
   - Neue Einträge bekommen automatisch Summary, alte nicht

2. **Komplexe Umstrukturierung**
   - Viele Spalten müssen geändert/umbenannt werden
   - Risiko von Datenverlust bei falscher Konfiguration
   - Alte Daten passen möglicherweise nicht zur neuen Struktur

3. **Fehleranfällig**
   - Ein Fehler kann alle bestehenden Daten betreffen
   - Schwer rückgängig zu machen
   - Kein einfacher Rollback möglich

### ✅ **Hybrid-Lösung (Beste Option)**

**Vorgehen:**

1. **Neue Datenbank "Hedy Events" erstellen**
   - Mit optimaler Struktur (siehe Prompt oben)
   - Alle Spalten korrekt konfigurieren
   - AI Summary aktivieren

2. **Alte Datenbank "Hedy Transkripte 0.9" behalten**
   - Als Archiv/Backup
   - Kann später gelöscht werden, wenn nicht mehr benötigt

3. **Workflow auf neue Datenbank umstellen**
   - Database ID in Notion-Node ändern
   - Properties anpassen (Spalten-Namen müssen exakt übereinstimmen)
   - Testen mit Test-Event

4. **Optional: Alte Daten migrieren**
   - Nur wenn gewünscht
   - Export → Import → AI Summary für alte Einträge generieren
   - Oder einfach alte Datenbank als Archiv behalten

**Vorteile dieser Lösung:**
- ✅ Keine Risiken für bestehende Daten
- ✅ Saubere neue Struktur
- ✅ AI Summary funktioniert optimal
- ✅ Einfacher Rollback möglich
- ✅ Parallel-Test möglich

---

## Workflow-Anpassung

Da die Zusammenfassung jetzt automatisch von Notion KI generiert wird, muss der Workflow angepasst werden:

**Entfernen:**
- `summary` Feld aus dem Parse-Node
- "Zusammenfassung" Property aus dem Notion-Node

**Beibehalten:**
- Alle anderen Felder bleiben gleich
- Notion KI generiert automatisch die Zusammenfassung basierend auf dem Inhalt

---

## Migration von alter Datenbank (optional)

Falls du Daten aus der alten Datenbank übernehmen möchtest:

1. **Export:**
   - Alte Datenbank → Export → CSV
   - Oder manuell kopieren

2. **Import:**
   - Neue Datenbank → Import → CSV
   - Spalten zuordnen

3. **Bereinigung:**
   - AI Summary für alte Einträge neu generieren
   - Event-Typ zuordnen (falls nicht vorhanden)
   - Status setzen (für Todos)

---

## Checkliste

- [ ] Neue Datenbank "Hedy Events" erstellen
- [ ] Alle 10 Spalten hinzufügen
- [ ] Event-Typ Select-Optionen konfigurieren
- [ ] Status Select-Optionen konfigurieren
- [ ] AI Summary aktivieren
- [ ] Views erstellen (8 Views)
- [ ] Workflow anpassen (summary entfernen)
- [ ] Workflow testen
- [ ] Alte Datenbank archivieren (optional)

