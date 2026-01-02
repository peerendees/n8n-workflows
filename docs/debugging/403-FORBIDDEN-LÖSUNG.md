# 🚫 403 Forbidden: "Authorization data is wrong!" - Lösung

## Fehler bestätigt

**Fehlermeldung:** `403 Forbidden - Authorization data is wrong!`

Das bedeutet: Der Header oder Token stimmt nicht mit der n8n-Konfiguration überein.

---

## Sofort-Lösung: Credential prüfen und anpassen

### Schritt 1: Credential in n8n öffnen

**In n8n:**
1. Workflow öffnen: "Hedy Webhook to Notion 0.9 - OPTIMIZED"
2. Klicke auf "Hedy API" Node
3. Klicke auf Credential "GitHub Token" (Stift-Icon)
4. **Wichtig:** Prüfe die Konfiguration:
   - **Name:** Welcher Header-Name? (`Authorization` oder `X-API-Key`?)
   - **Value:** Welcher Token? (Format: `Bearer TOKEN` oder nur `TOKEN`?)

### Schritt 2: Token und Format notieren

**Notiere dir:**
- Header-Name: `_________________`
- Token-Format: `_________________`
- Token-Wert: `_________________`

---

## Lösung Option A: Authorization Header (Standard)

### In n8n Credential prüfen:

**Erwartetes Format:**
```
Name: Authorization
Value: Bearer DEIN_TOKEN
```

### In Hedy konfigurieren:

**Settings → Webhooks → Header:**
```
Header Name: Authorization
Header Value: Bearer DEIN_TOKEN
```

**Wichtig:**
- `Bearer` muss vorhanden sein (mit Leerzeichen!)
- Token muss exakt übereinstimmen
- Groß-/Kleinschreibung beachten

---

## Lösung Option B: X-API-Key Header

### In n8n Credential prüfen:

**Erwartetes Format:**
```
Name: X-API-Key
Value: DEIN_TOKEN
```

### In Hedy konfigurieren:

**Settings → Webhooks → Header:**
```
Header Name: X-API-Key
Header Value: DEIN_TOKEN
```

**Wichtig:**
- Kein `Bearer` bei X-API-Key!
- Token muss exakt übereinstimmen

---

## Test: Welches Format funktioniert?

### Test 1: Authorization mit Bearer

```bash
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "Authorization: Bearer DEIN_TOKEN_HIER" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "session.ended",
    "data": {
      "id": "test",
      "title": "Test",
      "transcript": "Test"
    }
  }'
```

**Erwartung:**
- ✅ 200 OK → Format ist korrekt!
- ❌ 403 Forbidden → Format ist falsch, weiter zu Test 2

---

### Test 2: Authorization ohne Bearer

```bash
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "Authorization: DEIN_TOKEN_HIER" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "session.ended",
    "data": {"id": "test", "transcript": "Test"}
  }'
```

---

### Test 3: X-API-Key

```bash
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "X-API-Key: DEIN_TOKEN_HIER" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "session.ended",
    "data": {"id": "test", "transcript": "Test"}
  }'
```

---

## Häufige Fehlerquellen

### Fehler 1: "Bearer" fehlt oder falsch geschrieben

**Hedy sendet:**
```
Authorization: DEIN_TOKEN
```

**n8n erwartet:**
```
Authorization: Bearer DEIN_TOKEN
```

**Lösung:** In Hedy `Bearer ` (mit Leerzeichen) vor den Token setzen!

---

### Fehler 2: Falscher Header-Name

**Hedy sendet:**
```
Auth: Bearer TOKEN
```

**n8n erwartet:**
```
Authorization: Bearer TOKEN
```

**Lösung:** Header-Name muss exakt `Authorization` sein!

---

### Fehler 3: Token stimmt nicht überein

**Hedy sendet:**
```
Authorization: Bearer TOKEN_A
```

**n8n erwartet:**
```
Authorization: Bearer TOKEN_B
```

**Lösung:** Token aus n8n Credential kopieren und in Hedy einfügen!

---

### Fehler 4: Leerzeichen oder Sonderzeichen

**Hedy sendet:**
```
Authorization: Bearer  TOKEN  (doppelte Leerzeichen)
```

**n8n erwartet:**
```
Authorization: Bearer TOKEN  (ein Leerzeichen)
```

**Lösung:** Exakt ein Leerzeichen zwischen `Bearer` und Token!

---

## Schritt-für-Schritt Lösung

### 1. Token aus n8n kopieren

**In n8n:**
1. Credential "GitHub Token" öffnen
2. Token-Wert kopieren (komplett!)
3. Format notieren: Mit oder ohne "Bearer"?

### 2. In Hedy exakt gleich konfigurieren

**Settings → Webhooks:**
- Header Name: `Authorization` (oder wie in n8n konfiguriert)
- Header Value: Exakt wie in n8n (inkl. "Bearer" falls vorhanden)

### 3. Testen

**Neues YouTube-Video transkribieren:**
- Sollte jetzt funktionieren!
- Execution sollte in n8n erscheinen
- Eintrag sollte in Notion erstellt werden

---

## Alternative: Credential neu erstellen

Falls das Problem weiterhin besteht:

### Neues Credential in n8n:

1. **Credentials → Add Credential**
2. **Type:** Header Auth
3. **Name:** `Hedy Webhook Auth`
4. **Header Name:** `Authorization`
5. **Header Value:** `Bearer DEIN_TOKEN`

### Im Workflow:

1. "Hedy API" Node öffnen
2. Credential ändern zu "Hedy Webhook Auth"

### In Hedy:

1. Webhook konfigurieren:
   - Header Name: `Authorization`
   - Header Value: `Bearer DEIN_TOKEN` (exakt gleich!)

---

## Checkliste

- [ ] Credential in n8n geöffnet
- [ ] Header-Name notiert
- [ ] Token-Wert kopiert
- [ ] Format notiert (mit/ohne Bearer?)
- [ ] In Hedy exakt gleich konfiguriert
- [ ] Test-Webhook gesendet
- [ ] 200 OK statt 403 Forbidden?

---

## Nächste Schritte

1. **Credential in n8n prüfen** → Token und Format notieren
2. **In Hedy konfigurieren** → Exakt gleich wie in n8n
3. **Testen** → Neues Video transkribieren
4. **Prüfen** → Execution sollte erscheinen!

