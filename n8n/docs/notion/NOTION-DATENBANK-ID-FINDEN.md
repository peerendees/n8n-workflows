# 🔍 Notion Database ID finden und eintragen

## Problem

Die neue Datenbank "Hedy Events" taucht nicht in der Liste auf.

---

## Lösung: Database ID finden und eintragen

### Schritt 1: Database ID aus Notion kopieren

**In Notion:**

1. Öffne deine neue Datenbank "Hedy Events"
2. Klicke auf die **drei Punkte** (⋯) oben rechts
3. Klicke auf **"Copy link"**
4. Die URL sieht so aus:
   ```
   https://www.notion.so/2ca31cc6fd5680798a58d74ec1097a36?v=...
   ```
5. **Database ID:** `2ca31cc6fd5680798a58d74ec1097a36`
   - Das ist der Teil zwischen `/` und `?`
   - Format: 32 Zeichen (mit Bindestrichen)

**Alternative Methode:**

1. Database öffnen
2. URL kopieren
3. Database ID extrahieren:
   - Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - Oder: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` (ohne Bindestriche)

---

### Schritt 2: Database ID in n8n eintragen

**Im Notion-Node:**

1. **Database:** "By ID" auswählen
2. **Database ID:** Die kopierte ID einfügen
   - Format: `2ca31cc6-fd56-8079-8a58-d74ec1097a36`
   - Oder: `2ca31cc6fd5680798a58d74ec1097a36` (n8n konvertiert automatisch)

**Wichtig:**
- Database muss mit n8n verbunden sein (Connection)
- Database muss die richtigen Properties haben (siehe `NOTION-DATENBANK-PROMPT.md`)

---

## Database ID Format

**Notion URL Format:**
```
https://www.notion.so/2ca31cc6fd5680798a58d74ec1097a36?v=...
```

**Database ID (mit Bindestrichen):**
```
2ca31cc6-fd56-8079-8a58-d74ec1097a36
```

**Database ID (ohne Bindestriche):**
```
2ca31cc6fd5680798a58d74ec1097a36
```

**n8n akzeptiert beide Formate!**

---

## Prüfen: Database ist verbunden?

**In n8n:**

1. Notion-Node öffnen
2. Credential "API Notion" prüfen
3. Database sollte in der Liste erscheinen, wenn:
   - ✅ Credential korrekt ist
   - ✅ Database mit n8n verbunden ist
   - ✅ Database existiert

**Falls nicht in Liste:**
- Database ID manuell eintragen (By ID)
- Oder Database in Notion mit n8n verbinden

---

## Neue Database erstellen (falls noch nicht geschehen)

**Falls die neue Database noch nicht existiert:**

1. **Notion öffnen**
2. **Neue Database erstellen**
3. **Name:** "Hedy Events"
4. **Properties hinzufügen** (siehe `NOTION-DATENBANK-PROMPT.md`):
   - Titel (title)
   - Event-Typ (select)
   - Status (select)
   - Transkript (rich_text)
   - Session ID (text)
   - Session Titel (text)
   - Erstellungsdatum (date)
   - Due Date (date)
   - Zusammenfassung (AI Summary - automatisch)

5. **Database ID kopieren** (siehe oben)
6. **In n8n eintragen**

---

## Quick Copy: Database ID Format

**Aus Notion URL:**
```
https://www.notion.so/2ca31cc6fd5680798a58d74ec1097a36?v=...
```

**Für n8n:**
```
2ca31cc6-fd56-8079-8a58-d74ec1097a36
```

**Oder:**
```
2ca31cc6fd5680798a58d74ec1097a36
```

---

## Checkliste

- [ ] Neue Database "Hedy Events" erstellt?
- [ ] Database ID aus Notion kopiert?
- [ ] Database ID in n8n eingetragen (By ID)?
- [ ] Properties korrekt konfiguriert?
- [ ] Credential "API Notion" korrekt?
- [ ] Test-Webhook gesendet?

