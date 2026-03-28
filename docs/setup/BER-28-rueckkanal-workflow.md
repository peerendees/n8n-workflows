# Cursor-Briefing: BERENT Commit-Sync Linear

**Datum:** 28. März 2026
**Linear-Issue:** [BER-28](https://linear.app/berent/issue/BER-28/n8n-workflow-cursor-done-linear-threema-notion-ruckkanal)
**Projekt:** n8n & Infrastruktur
**Komplexität:** Mittel

---

## Ziel

Einen n8n-Workflow erstellen, der automatisch reagiert, wenn Cursor einen Commit mit `[BER-XX] done: Beschreibung` pushed. Der Workflow setzt das Linear-Issue auf Done, schickt eine Threema-Nachricht und schreibt einen Notion-Kommentar auf den PARA-Hub.

## Kontext

### Warum

Aktuell muss nach jeder Cursor-Umsetzung manuell zurück zu Claude gewechselt werden, um Issues zu closen und den PARA-Hub zu aktualisieren. Der Rückkanal automatisiert den operativen Teil (Linear + Threema). Den intelligenten Teil (PARA-Hub-Dashboard) übernimmt Claude beim nächsten Chat, getriggert durch den Notion-Kommentar.

### Signalkette

```
Cursor commit + push
  → GitHub Webhook → n8n
    → Commit-Message parsen [BER-XX] done: ...
    → Linear API: Issue auf Done
    → Threema: Benachrichtigung an Marcus
    → Notion: Kommentar auf PARA-Hub ("Dashboard-Update ausstehend")
```

### Workspace

Repo: `peerendees/n8n-workflows` (lokaler Klon = Cursor-Workspace)

### Bestehende Infrastruktur

- **n8n-Instanz:** `https://n8n.srv1098810.hstgr.cloud/`
- **GitHub Backup-Workflow** (ID: `49W0_QAnGHo78Vzt0XBfx`): Aktiv, pushed n8n-Workflows nach GitHub in Ordner `n8n/<workflow-id>/`
- **GitHub → n8n Sync** (ID: `499J5QUt4xUoTujR`): Aktiv, importiert Workflows aus GitHub nach n8n
- **Threema Gateway:** `$env.THREEMA_GATEWAY_ID`, `$env.THREEMA_RECIPIENT_ID`, `$env.THREEMA_API_SECRET` — bereits als n8n-Environment-Variables konfiguriert
- **Bestehender Threema-Workflow** (`hR36jIx0wREZK0Bf`): "Threema Gateway Universal" — inaktiv, aber als Referenz für die Threema-API nutzbar

### Linear-Referenzen

- **Done-State-ID:** `71127dd5-e5f5-412a-89e5-83260040c02b`
- **Linear-Issue-Format:** `BER-XX` (Identifier, nicht die UUID)
- **Linear GraphQL Endpoint:** `https://api.linear.app/graphql`
- **Linear API-Key:** muss als n8n-Credential vorhanden sein (HTTP Header Auth, `Authorization: <api-key>`)

### Notion-Referenzen

- **PARA-Hub Page-ID:** `33131cc6-fd56-8102-b0d7-d10557364753`
- **Notion Comments API:** `POST https://api.notion.com/v1/comments`
- **Notion-Version Header:** `2022-06-28`
- **Notion API-Key:** muss als n8n-Credential vorhanden sein (HTTP Header Auth, `Authorization: Bearer <token>`)

---

## Umsetzung

### Schritt 1: Draft-Ordner anlegen

```bash
mkdir -p drafts/
```

Im Repo `peerendees/n8n-workflows` wird ein Ordner `drafts/` erstellt für Workflow-Entwürfe, die noch nicht in n8n importiert sind.

### Schritt 2: Workflow-JSON erstellen

Datei: `drafts/cursor-done-rueckkanal.json`

Der Workflow besteht aus 7 Nodes:

**1. Webhook Trigger** (n8n-nodes-base.webhook)
- Methode: POST
- Path: `cursor-done-rueckkanal`
- Wird später als GitHub-Webhook in `peerendees/berent.ai` eingetragen
- Produktions-URL: `https://n8n.srv1098810.hstgr.cloud/webhook/cursor-done-rueckkanal`

**2. Commit-Message parsen** (n8n-nodes-base.code)
- Mode: runOnceForAllItems
- Regex: `/\[BER-(\d+)\]\s*done:?\s*(.*)/i`
- Input: `$json.body.commits` (GitHub-Webhook-Payload)
- Output: `{ issueId, description, commitSha, matched }`

**3. BER-Pattern gefunden?** (n8n-nodes-base.if)
- Bedingung: `$json.matched === true`
- True-Branch → weiter zu Linear
- False-Branch → Ende (ignorieren)

**4. Linear → Done** (n8n-nodes-base.httpRequest)
- POST `https://api.linear.app/graphql`
- Auth: HTTP Header Auth (Linear API Key)
- Body (GraphQL):
```graphql
mutation {
  issueUpdate(
    id: "{{ $json.issueId }}"
    input: { stateId: "71127dd5-e5f5-412a-89e5-83260040c02b" }
  ) {
    success
    issue { identifier title state { name } }
  }
}
```
**Wichtig:** Die Linear GraphQL API akzeptiert den `identifier` (BER-XX) als `id`-Parameter — das muss getestet werden. Falls nicht: zusätzlichen Lookup-Schritt einbauen, der die UUID über `identifier` resolved.

**5. Threema Benachrichtigung** (n8n-nodes-base.httpRequest)
- POST `https://msgapi.threema.ch/send_simple`
- Content-Type: `application/x-www-form-urlencoded`
- Body-Parameter:
  - `from`: `{{ $env.THREEMA_GATEWAY_ID }}`
  - `to`: `{{ $env.THREEMA_RECIPIENT_ID }}`
  - `secret`: `{{ $env.THREEMA_API_SECRET }}`
  - `text`: `✅ {{ issueId }} erledigt: {{ description }}. PARA-Hub-Update steht aus.`

**6. Notion PARA-Hub Kommentar** (n8n-nodes-base.httpRequest)
- POST `https://api.notion.com/v1/comments`
- Auth: HTTP Header Auth (Notion Bearer Token)
- Header: `Notion-Version: 2022-06-28`
- Body:
```json
{
  "parent": { "page_id": "33131cc6-fd56-8102-b0d7-d10557364753" },
  "rich_text": [{
    "type": "text",
    "text": {
      "content": "BER-XX erledigt am YYYY-MM-DD. Dashboard-Update ausstehend."
    }
  }]
}
```

**7. Ergebnis** (n8n-nodes-base.code)
- Zusammenfassung: welche Schritte erfolgreich, welche fehlgeschlagen

### Schritt 3: Draft committen

```bash
git add drafts/cursor-done-rueckkanal.json
git commit -m "feat(BER-28): Draft Rückkanal-Workflow Cursor Done → Linear + Threema + Notion"
git push
```

### Schritt 4: In n8n importieren

Zwei Optionen:

**Option A — n8n UI:**
1. n8n öffnen → Workflows → Import from File → `drafts/cursor-done-rueckkanal.json`
2. n8n vergibt automatisch eine Workflow-ID
3. Credentials zuweisen (Linear API Key, Notion Bearer Token, GitHub PAT für den Trigger)
4. Der Backup-Workflow pushed den importierten Workflow automatisch nach GitHub (mit ID-Ordner)

**Option B — n8n API:**
Wenn ein n8n-API-Endpoint zum Import verfügbar ist, diesen nutzen. Aber Option A ist zuverlässiger für den ersten Import.

### Schritt 5: GitHub-Webhook einrichten

Im Repo `peerendees/berent.ai` (Settings → Webhooks):
- Payload URL: `https://n8n.srv1098810.hstgr.cloud/webhook/cursor-done-rueckkanal`
- Content type: `application/json`
- Events: „Just the push event"
- Active: Ja

**Hinweis:** Das berent.ai-Repo hat möglicherweise bereits Webhooks (für den Backup-Workflow). Einen zusätzlichen hinzufügen, nicht den bestehenden ersetzen.

### Schritt 6: Credentials zuweisen

In n8n die drei HTTP-Request-Nodes konfigurieren:

1. **Linear → Done:** Authentication auf „Generic Credential Type" → „HTTP Header Auth" umstellen. Credential: `Authorization` = `<Linear API Key>` (kein Bearer-Prefix, Linear erwartet den Key direkt)

2. **Notion PARA-Hub Kommentar:** Authentication auf „Generic Credential Type" → „HTTP Header Auth" umstellen. Credential: `Authorization` = `Bearer <Notion Internal Integration Token>`

3. **Threema Benachrichtigung:** Bleibt bei `$env`-Variablen, keine Credential-Änderung nötig.

### Schritt 7: Testen

1. Workflow in n8n auf „Active" setzen
2. Im Repo `peerendees/berent.ai` einen Test-Commit machen:
```bash
echo "test" >> test-rueckkanal.txt
git add test-rueckkanal.txt
git commit -m "[BER-99] done: Testcommit für Rückkanal"
git push
```
3. Prüfen:
   - [ ] n8n Execution Log: Workflow wurde getriggert
   - [ ] Commit-Message wurde korrekt geparst (issueId = BER-99)
   - [ ] If-Node: True-Branch genommen
   - [ ] Linear: BER-99 existiert nicht → Fehler erwartet (OK für den Test)
   - [ ] Threema: Nachricht empfangen
   - [ ] Notion: Kommentar auf PARA-Hub sichtbar
4. Test-Datei aufräumen:
```bash
git rm test-rueckkanal.txt
git commit -m "chore: Testdatei entfernt"
git push
```

---

## Akzeptanzkriterien

- [ ] Ordner `drafts/` existiert im Repo `peerendees/n8n-workflows`
- [ ] Workflow-JSON liegt in `drafts/cursor-done-rueckkanal.json`
- [ ] Workflow ist in n8n importiert und hat eine ID
- [ ] Credentials sind zugewiesen (Linear, Notion)
- [ ] GitHub-Webhook ist eingerichtet für `peerendees/berent.ai`
- [ ] Ein Commit mit `[BER-XX] done: ...` triggert den Workflow
- [ ] Linear-Issue wird auf Done gesetzt
- [ ] Threema-Nachricht kommt an
- [ ] Notion-Kommentar erscheint auf dem PARA-Hub

## Dateien

- `drafts/cursor-done-rueckkanal.json` — neu erstellen
- GitHub Webhook-Konfiguration — in `peerendees/berent.ai` Settings

## Offene Fragen für die Umsetzung

1. **Linear-Identifier vs. UUID:** Akzeptiert die GraphQL-Mutation `id: "BER-28"` als Identifier oder braucht es die UUID? Falls letzteres: einen `issueByIdentifier`-Query vorschalten.
2. **Mehrere Repos:** Der Workflow lauscht aktuell nur auf `peerendees/berent.ai`. Soll er auch auf andere Repos reagieren (z.B. `peerendees/n8n-workflows`, `peerendees/vaaas`)? Wenn ja: Webhook in allen Repos eintragen oder auf GitHub-Trigger-Node mit mehreren Repos umstellen.
3. **Error Handling:** Was passiert wenn ein Schritt fehlschlägt (z.B. Linear-API down)? Aktuell: Kette bricht ab. Alternative: Fehler auffangen und trotzdem Threema senden.

---

## Abschluss

Wenn alle Änderungen umgesetzt sind:
```bash
git add -A
git commit -m "[BER-28] done: Rückkanal-Workflow Cursor Done erstellt und getestet"
git push
```
Dieser Commit triggert den automatischen Rückkanal (Linear → Done, Threema-Benachrichtigung, Notion-Marker).
