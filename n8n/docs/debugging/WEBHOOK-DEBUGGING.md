# 🔍 Webhook-Debugging: Warum keine Execution?

## Problem

YouTube-Video wurde in Hedy transkribiert, aber:
- ❌ Keine Execution in n8n
- ❌ Kein Eintrag in Notion

---

## Mögliche Ursachen

### 1. **Workflow nicht aktiv**
- Workflow muss in n8n aktiviert sein
- Webhook funktioniert nur bei aktiven Workflows

### 2. **Webhook nicht korrekt konfiguriert in Hedy**
- Hedy muss den Webhook-URL kennen
- Webhook muss in Hedy aktiviert sein

### 3. **Webhook-URL falsch**
- URL muss exakt übereinstimmen
- Pfad muss korrekt sein: `/webhook/Hedy-Todos`

### 4. **Authentifizierung fehlt**
- Header Auth muss korrekt konfiguriert sein
- Token muss in Hedy gesetzt sein

### 5. **Hedy sendet Webhook nicht**
- Event-Typ nicht konfiguriert
- Webhook nicht aktiviert für diesen Event-Typ

---

## Debugging-Schritte

### Schritt 1: Workflow-Status prüfen

**In n8n:**
1. Öffne Workflow "Hedy Webhook to Notion 0.9 - OPTIMIZED"
2. Prüfe ob Workflow **aktiv** ist (Toggle oben rechts)
3. Falls nicht aktiv: Aktivieren

**Webhook-URL kopieren:**
1. Klicke auf "Hedy API" Node
2. Kopiere die Webhook-URL (z.B. `https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos`)

---

### Schritt 2: Webhook manuell testen

**Test mit curl:**
```bash
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "Authorization: Bearer DEIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "session.ended",
    "data": {
      "id": "test_session_123",
      "title": "Test Session",
      "transcript": "This is a test transcript"
    },
    "timestamp": "2024-12-23T18:00:00Z"
  }'
```

**Erwartetes Ergebnis:**
- Execution sollte in n8n erscheinen
- Eintrag sollte in Notion erstellt werden

---

### Schritt 3: Hedy Webhook-Konfiguration prüfen

**In Hedy prüfen:**
1. Gehe zu Settings → Webhooks
2. Prüfe ob Webhook konfiguriert ist:
   - URL: `https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos`
   - Authentifizierung: Header Auth mit Token
   - Events: `session.created`, `session.ended`, `highlight.created`, `todo.exported`

**Wichtig:**
- Alle Event-Typen müssen aktiviert sein
- URL muss exakt übereinstimmen
- Token muss korrekt sein

---

### Schritt 4: Execution-Logs prüfen

**In n8n:**
1. Gehe zu "Executions" Tab
2. Prüfe ob überhaupt eine Execution vorhanden ist
3. Falls ja: Öffne und prüfe Fehler

**Falls keine Execution:**
- Webhook wurde nicht ausgelöst
- Problem liegt bei Hedy oder Webhook-Konfiguration

---

### Schritt 5: Webhook-Logs in Hedy prüfen

**In Hedy:**
1. Gehe zu Webhook-Logs oder Activity
2. Prüfe ob Webhook gesendet wurde
3. Prüfe HTTP-Status-Code:
   - 200 = Erfolg
   - 401 = Authentifizierung fehlgeschlagen
   - 404 = Webhook nicht gefunden
   - 500 = Server-Fehler

---

## Häufige Probleme und Lösungen

### Problem 1: Webhook-URL falsch

**Symptom:** Keine Execution in n8n

**Lösung:**
- Prüfe Webhook-URL in Hedy
- Muss exakt sein: `https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos`
- Keine zusätzlichen Slashes oder Pfade

---

### Problem 2: Authentifizierung fehlt

**Symptom:** 401 Fehler in Hedy-Logs

**Lösung:**
- Prüfe Header Auth Token in Hedy
- Muss mit Token in n8n übereinstimmen
- Format: `Authorization: Bearer TOKEN` oder `X-API-Key: TOKEN`

---

### Problem 3: Event-Typ nicht aktiviert

**Symptom:** Webhook wird gesendet, aber nicht empfangen

**Lösung:**
- In Hedy: Alle Event-Typen aktivieren:
  - ✅ `session.created`
  - ✅ `session.ended`
  - ✅ `highlight.created`
  - ✅ `todo.exported`

---

### Problem 4: Workflow nicht aktiv

**Symptom:** Webhook existiert, aber keine Execution

**Lösung:**
- In n8n: Workflow aktivieren (Toggle oben rechts)
- Webhook funktioniert nur bei aktiven Workflows

---

## Schnelltest

### Test 1: Webhook erreichbar?

```bash
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "Authorization: Bearer DEIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

**Erwartung:**
- Execution sollte in n8n erscheinen
- Auch wenn Daten nicht korrekt sind

---

### Test 2: Workflow aktiv?

**In n8n:**
- Workflow öffnen
- Prüfe Toggle oben rechts: Muss **ON** sein

---

### Test 3: Hedy sendet Webhook?

**In Hedy:**
- Webhook-Logs prüfen
- Sollte zeigen: "Webhook gesendet" oder Fehler

---

## Nächste Schritte

1. **Workflow aktivieren** (falls nicht aktiv)
2. **Webhook-URL in Hedy prüfen**
3. **Event-Typen in Hedy aktivieren**
4. **Test-Webhook senden** (mit curl)
5. **Execution-Logs prüfen**

---

## Checkliste

- [ ] Workflow ist aktiv in n8n?
- [ ] Webhook-URL ist korrekt in Hedy?
- [ ] Authentifizierung ist konfiguriert?
- [ ] Event-Typen sind aktiviert in Hedy?
- [ ] Test-Webhook funktioniert?
- [ ] Execution-Logs zeigen Fehler?

