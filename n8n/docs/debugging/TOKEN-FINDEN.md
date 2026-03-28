# 🔑 Token finden: Woher kommt DEIN_TOKEN?

## Token-Quelle: n8n Credential

Das Token kommt aus dem **Credential "GitHub Token"** im n8n Workflow.

---

## Schritt-für-Schritt: Token aus n8n holen

### Schritt 1: Workflow öffnen

1. Öffne n8n
2. Gehe zu Workflows
3. Öffne: **"Hedy Webhook to Notion 0.9 - OPTIMIZED"**

### Schritt 2: Webhook-Node öffnen

1. Klicke auf den **"Hedy API"** Node (Webhook-Node)
2. Im Node-Panel siehst du:
   - **Authentication:** Header Auth
   - **Credential for Header Auth:** GitHub Token

### Schritt 3: Credential öffnen

1. Klicke auf **"GitHub Token"** (oder das Stift-Icon daneben)
2. Das Credential öffnet sich
3. **Wichtig:** Du siehst jetzt:
   - **Name:** Header-Name (z.B. `Authorization` oder `X-API-Key`)
   - **Value:** **Das ist dein Token!** 👈

### Schritt 4: Token kopieren

1. Kopiere den **Value** (Token-Wert)
2. **Wichtig:** Prüfe auch das Format:
   - Enthält es `Bearer ` am Anfang?
   - Oder ist es nur der Token ohne `Bearer`?

---

## Beispiel: Was du siehst

### Option A: Mit Bearer

```
Name: Authorization
Value: Bearer abc123xyz789...
```

**→ Token für httpie:** `abc123xyz789...` (ohne "Bearer")
**→ Header:** `Authorization:"Bearer abc123xyz789..."`

### Option B: Ohne Bearer

```
Name: Authorization
Value: abc123xyz789...
```

**→ Token für httpie:** `abc123xyz789...`
**→ Header:** `Authorization:"Bearer abc123xyz789..."` (Bearer hinzufügen!)

### Option C: X-API-Key

```
Name: X-API-Key
Value: abc123xyz789...
```

**→ Token für httpie:** `abc123xyz789...`
**→ Header:** `X-API-Key:"abc123xyz789..."` (kein Bearer!)

---

## Token in httpie verwenden

### Wenn Credential "Authorization" mit "Bearer TOKEN" hat:

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer abc123xyz789..." \
  event=session.ended \
  data:='{"id":"test","transcript":"test"}'
```

### Wenn Credential "Authorization" ohne "Bearer" hat:

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  Authorization:"Bearer abc123xyz789..." \
  event=session.ended \
  data:='{"id":"test","transcript":"test"}'
```
(Beide sind gleich - httpie fügt Bearer hinzu oder du fügst es manuell hinzu)

### Wenn Credential "X-API-Key" hat:

```bash
http POST https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Todos \
  X-API-Key:"abc123xyz789..." \
  event=session.ended \
  data:='{"id":"test","transcript":"test"}'
```

---

## Alternative: Token aus n8n API holen

Falls du das Credential nicht öffnen kannst:

### Mit n8n API:

```bash
# Hole Workflow-Details
curl -X GET \
  "https://n8n.srv1098810.hstgr.cloud/api/v1/workflows/p4WBXmtWQqToEtLw" \
  -H "X-N8N-API-KEY: DEIN_N8N_API_KEY"
```

**Aber:** Credentials werden aus Sicherheitsgründen nicht in der API zurückgegeben!

---

## Empfehlung: Credential direkt öffnen

**Am einfachsten:**
1. Workflow öffnen
2. "Hedy API" Node öffnen
3. Credential "GitHub Token" öffnen
4. Token kopieren
5. Format notieren (mit/ohne Bearer?)

---

## Checkliste

- [ ] Workflow geöffnet
- [ ] "Hedy API" Node geöffnet
- [ ] Credential "GitHub Token" geöffnet
- [ ] Token-Wert kopiert
- [ ] Format notiert (mit/ohne Bearer?)
- [ ] Header-Name notiert (Authorization oder X-API-Key?)

---

## Wichtig für Hedy-Konfiguration

**Das gleiche Token und Format muss in Hedy verwendet werden:**

**In Hedy (Settings → Webhooks):**
- Header Name: Wie in n8n Credential (z.B. `Authorization`)
- Header Value: Exakt wie in n8n Credential (z.B. `Bearer abc123xyz789...`)

**Wenn n8n Credential hat:**
```
Name: Authorization
Value: Bearer abc123xyz789...
```

**Dann in Hedy:**
```
Header Name: Authorization
Header Value: Bearer abc123xyz789...
```

**Exakt gleich!**

