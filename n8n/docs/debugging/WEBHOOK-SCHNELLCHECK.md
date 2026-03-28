# ⚡ Webhook-Schnellcheck: Keine Execution?

## Sofort-Checkliste

### ✅ Schritt 1: Workflow aktiv?
**In n8n:**
- Workflow öffnen: "Hedy Webhook to Notion 0.9 - OPTIMIZED"
- Toggle oben rechts muss **ON** sein
- Falls OFF: Aktivieren und speichern

### ✅ Schritt 2: Webhook-URL kopieren
**In n8n:**
1. Klicke auf "Hedy API" Node
2. Kopiere die Webhook-URL (zeigt n8n an)
3. Beispiel: `https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos`

### ✅ Schritt 3: Webhook in Hedy konfigurieren
**In Hedy (Settings → Webhooks):**

1. **Webhook hinzufügen/bearbeiten:**
   - URL: `https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos`
   - Authentifizierung: Header Auth
   - Header Name: `Authorization` oder `X-API-Key`
   - Header Value: Dein Token (muss mit n8n übereinstimmen)

2. **Event-Typen aktivieren:**
   - ✅ `session.created`
   - ✅ `session.ended` ← **WICHTIG für Transkripte!**
   - ✅ `highlight.created`
   - ✅ `todo.exported`

### ✅ Schritt 4: Test-Webhook senden
**Mit curl testen:**
```bash
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "Authorization: Bearer DEIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "session.ended",
    "data": {
      "id": "test_123",
      "title": "Test Session",
      "transcript": "Test transcript"
    },
    "timestamp": "2024-12-23T18:00:00Z"
  }'
```

**Erwartung:**
- Execution sollte in n8n erscheinen
- Eintrag sollte in Notion erstellt werden

---

## Häufigste Probleme

### Problem 1: Workflow nicht aktiv
**Symptom:** Keine Execution, auch bei Test-Webhook

**Lösung:** Workflow aktivieren (Toggle oben rechts)

---

### Problem 2: Webhook nicht in Hedy konfiguriert
**Symptom:** Session erstellt, aber kein Webhook gesendet

**Lösung:** 
- In Hedy: Settings → Webhooks
- Webhook hinzufügen mit korrekter URL
- Event-Typen aktivieren

---

### Problem 3: Falsche Authentifizierung
**Symptom:** 401 Fehler in Hedy-Logs

**Lösung:**
- Token in Hedy muss mit Token in n8n übereinstimmen
- Header-Name prüfen: `Authorization` oder `X-API-Key`

---

### Problem 4: Event-Typ nicht aktiviert
**Symptom:** Webhook wird gesendet, aber nicht empfangen

**Lösung:**
- In Hedy: Alle Event-Typen aktivieren
- Besonders wichtig: `session.ended` (enthält Transkript!)

---

## Nächste Schritte

1. **Workflow aktivieren** (falls nicht aktiv)
2. **Webhook-URL aus n8n kopieren**
3. **In Hedy konfigurieren:**
   - URL einfügen
   - Authentifizierung setzen
   - Event-Typen aktivieren
4. **Test-Webhook senden** (mit curl)
5. **Prüfen:** Execution in n8n?

---

## Debugging-Tools

### Execution-Logs prüfen:
```bash
# Mit unseren Scripts
export N8N_API_KEY="dein-key"
./find-failed-executions.sh <workflow-id>
```

### Webhook-Logs in Hedy:
- Gehe zu Webhook-Logs/Activity
- Prüfe ob Webhook gesendet wurde
- Prüfe HTTP-Status-Code

