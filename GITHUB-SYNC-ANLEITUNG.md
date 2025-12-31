# 📤 GitHub-Synchronisation: Neue Dateien hochladen

## Aktuelle Situation

### Was automatisch gesichert wird:

Der Workflow `n8n → GitHub Sicherung` sichert automatisch:
- ✅ Alle n8n-Workflows aus deiner n8n-Instanz
- ✅ Speichert sie in `n8n/{workflowId}/{workflowName}.json`
- ✅ Läuft alle 15 Minuten automatisch

### Was NICHT automatisch gesichert wird:

- ❌ Lokale Markdown-Dateien (`.md`)
- ❌ Lokale Scripts (`.sh`)
- ❌ Lokale JSON-Dateien außerhalb von n8n
- ❌ Neue Workflow-Dateien, die noch nicht in n8n importiert wurden

---

## Neue Dateien manuell hochladen

### Option 1: Git-Befehle (Empfohlen)

```bash
# 1. Alle neuen Dateien hinzufügen
git add .

# 2. Commit erstellen
git commit -m "📝 Neue Dokumentation und Workflows hinzugefügt

- Hedy API Analyse und Workflows
- Notion-Datenbank Setup-Anleitung
- Debug-Scripts und Anleitungen
- Optimierte Workflows für Hedy → Notion"

# 3. Nach GitHub pushen
git push origin main
```

### Option 2: Schritt für Schritt

```bash
# 1. Status prüfen
git status

# 2. Spezifische Dateien hinzufügen
git add "Hedy Webhook to Notion 0.9 - OPTIMIZED.json"
git add "NOTION-DATENBANK-PROMPT.md"
git add "COACHING-SESSION-ABLAUF.md"
# ... weitere Dateien

# 3. Commit
git commit -m "Hedy Workflows und Dokumentation hinzugefügt"

# 4. Push
git push origin main
```

---

## Neue Dateien automatisch sichern (Erweiterung)

### Option A: Workflow erweitern

Der bestehende Backup-Workflow könnte erweitert werden, um auch lokale Dateien zu sichern:

**Neue Funktion:**
- Lokale Dateien lesen
- Nach GitHub pushen (falls geändert)
- Nur neue/geänderte Dateien

**Nachteil:**
- Komplexer
- Benötigt Git-Integration in n8n

### Option B: Git-Hook verwenden

**Pre-commit Hook:**
- Automatisch alle Dateien committen
- Nach GitHub pushen

**Nachteil:**
- Muss lokal eingerichtet werden
- Nicht für alle Dateien gewünscht

### Option C: GitHub Actions (Empfohlen für Automatisierung)

**GitHub Action erstellen:**
- Läuft auf GitHub selbst
- Kann Dateien von n8n API holen
- Kann lokale Änderungen pushen

**Vorteil:**
- Läuft automatisch
- Keine lokale Konfiguration nötig

---

## Schnelllösung: Einmalig alle Dateien hochladen

```bash
# Alle neuen Dateien hinzufügen
git add .

# Commit
git commit -m "📝 Hedy Workflows und Dokumentation

- Hedy API Analyse und Workflows
- Notion-Datenbank Setup-Anleitung  
- Debug-Scripts und Anleitungen
- Optimierte Workflows für Hedy → Notion Integration"

# Push
git push origin main
```

---

## Workflow-Status prüfen

### Welche Dateien sind neu?

```bash
# Zeige alle neuen/geänderten Dateien
git status

# Zeige nur neue Dateien
git status | grep "??"
```

### Dateien vor Commit prüfen

```bash
# Zeige Änderungen
git diff

# Zeige neue Dateien
git ls-files --others --exclude-standard
```

---

## Empfehlung

### Für jetzt: Manuell committen

1. **Alle neuen Dateien hinzufügen:**
   ```bash
   git add .
   ```

2. **Commit erstellen:**
   ```bash
   git commit -m "Hedy Workflows und Dokumentation hinzugefügt"
   ```

3. **Nach GitHub pushen:**
   ```bash
   git push origin main
   ```

### Für später: Automatisierung prüfen

- Der Backup-Workflow sichert bereits n8n-Workflows automatisch
- Lokale Dokumentation könnte auch automatisiert werden
- Aber: Manuelle Commits geben mehr Kontrolle

---

## Checkliste

- [ ] Neue Dateien identifiziert (`git status`)
- [ ] Dateien hinzugefügt (`git add .`)
- [ ] Commit erstellt (`git commit`)
- [ ] Nach GitHub gepusht (`git push`)
- [ ] Auf GitHub verifiziert (Repository prüfen)

