# 🔐 Header Auth Lösung: Authentifizierungsfehler beheben

## Problem

Hedy sendet Webhook, aber Authentifizierung schlägt fehl.

---

## n8n Webhook Header Auth Konfiguration

### Wie n8n Header Auth erwartet:

**Standard-Format:**
- Header Name: `Authorization`
- Header Value: `Bearer TOKEN` oder `TOKEN`

**Alternative Formate:**
- Header Name: `X-API-Key`
- Header Value: `TOKEN`

---

## Lösung: Credential in n8n prüfen

### Schritt 1: Credential öffnen

**In n8n:**
1. Gehe zu Credentials
2. Öffne "GitHub Token" (ID: `aZMd0okvVFkvyGnj`)
3. Prüfe Konfiguration:
   - **Name:** Header-Name (z.B. `Authorization` oder `X-API-Key`)
   - **Value:** Token-Wert

### Schritt 2: Header-Format prüfen

**n8n erwartet standardmäßig:**
```
Authorization: Bearer TOKEN
```

**Oder:**
```
X-API-Key: TOKEN
```

---

## Lösung: Hedy Webhook konfigurieren

### In Hedy (Settings → Webhooks):

**Option 1: Authorization Header**
```
Header Name: Authorization
Header Value: Bearer DEIN_TOKEN
```

**Option 2: X-API-Key Header**
```
Header Name: X-API-Key
Header Value: DEIN_TOKEN
```

**Wichtig:**
- Token muss mit Token in n8n übereinstimmen
- Header-Name muss mit Credential in n8n übereinstimmen

---

## Debugging: Welcher Header wird erwartet?

### Schritt 1: Credential in n8n prüfen

1. Workflow öffnen
2. "Hedy API" Node öffnen
3. Credential "GitHub Token" öffnen (Stift-Icon)
4. Prüfe:
   - **Name:** Welcher Header-Name ist konfiguriert?
   - **Value:** Welcher Token ist gesetzt?

### Schritt 2: Test-Webhook mit verschiedenen Headers

**Test 1: Authorization Header**
```bash
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "Authorization: Bearer DEIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "session.ended",
    "data": {"id": "test", "title": "Test", "transcript": "Test"}
  }'
```

**Test 2: X-API-Key Header**
```bash
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "X-API-Key: DEIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "session.ended",
    "data": {"id": "test", "title": "Test", "transcript": "Test"}
  }'
```

**Welcher funktioniert?** → Dieser Header muss in Hedy konfiguriert werden!

---

## Häufige Fehler

### Fehler 1: "Bearer" fehlt

**Hedy sendet:**
```
Authorization: TOKEN
```

**n8n erwartet:**
```
Authorization: Bearer TOKEN
```

**Lösung:** In Hedy `Bearer TOKEN` verwenden (mit Leerzeichen!)

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

**Lösung:** Header-Name muss exakt `Authorization` sein

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

**Lösung:** Token muss identisch sein!

---

## Empfohlene Konfiguration

### In n8n (Credential):

**Name:** `Authorization`  
**Value:** `Bearer DEIN_TOKEN_HIER`

### In Hedy (Webhook):

**Header Name:** `Authorization`  
**Header Value:** `Bearer DEIN_TOKEN_HIER` (exakt gleich wie in n8n!)

---

## Test-Prozedur

### 1. Token aus n8n kopieren

**In n8n:**
1. Credential "GitHub Token" öffnen
2. Token-Wert kopieren
3. Format notieren: `Bearer TOKEN` oder nur `TOKEN`?

### 2. In Hedy konfigurieren

**Settings → Webhooks:**
- Header Name: `Authorization` (oder wie in n8n konfiguriert)
- Header Value: Exakt wie in n8n (inkl. "Bearer" falls vorhanden)

### 3. Test-Webhook senden

```bash
# Verwende exakt den gleichen Header wie in Hedy konfiguriert
curl -X POST \
  "https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos" \
  -H "Authorization: Bearer DEIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"event": "session.ended", "data": {"id": "test", "transcript": "test"}}'
```

### 4. Prüfen

- Execution sollte in n8n erscheinen
- Keine Authentifizierungsfehler

---

## Alternative: Credential neu erstellen

Falls das Problem weiterhin besteht:

### Neues Credential erstellen:

1. **In n8n:**
   - Credentials → Add Credential
   - Type: Header Auth
   - Name: `Hedy Webhook Token`
   - Header Name: `Authorization`
   - Header Value: `Bearer DEIN_TOKEN`

2. **Im Workflow:**
   - "Hedy API" Node öffnen
   - Credential ändern zu "Hedy Webhook Token"

3. **In Hedy:**
   - Webhook konfigurieren mit neuem Token

---

## Checkliste

- [ ] Credential in n8n geöffnet und geprüft
- [ ] Header-Name notiert (Authorization oder X-API-Key?)
- [ ] Token-Wert notiert (mit oder ohne "Bearer"?)
- [ ] In Hedy exakt gleich konfiguriert
- [ ] Test-Webhook gesendet
- [ ] Execution erscheint ohne Fehler

