# ✅ Backup-Workflow Prüfung

## Was passiert beim Backup?

Der Backup-Workflow (`n8n → GitHub Sicherung`) sollte:

1. ✅ Alle Workflows aus n8n holen
2. ✅ In neuer Struktur speichern: `n8n/{workflowId}/{workflowName}.json`
3. ✅ Nach GitHub pushen
4. ✅ Threema-Benachrichtigung senden (falls konfiguriert)

---

## Prüfung: Hat das Backup funktioniert?

### Option 1: Auf GitHub prüfen

1. Gehe zu: https://github.com/peerendees/n8n-workflows
2. Navigiere zu: `n8n/` Verzeichnis
3. Suche nach: `{workflowId}/` Ordner mit deinem geänderten Workflow
4. Prüfe: Wurde der Workflow aktualisiert?

### Option 2: Lokal prüfen (nach Git Pull)

Auf Rechner 1 oder Rechner 2:

```bash
cd ~/n8n-workflows
git pull origin main

# Prüfe, ob neue Dateien/Ordner erstellt wurden
ls -la n8n/

# Prüfe Git-Log für Backup-Commits
git log --oneline --grep="Workflow-Backup" -10
```

### Option 3: In n8n prüfen

1. Öffne den Backup-Workflow in n8n
2. Gehe zu "Executions" (Ausführungen)
3. Prüfe die letzte Ausführung:
   - ✅ Status: "Success"
   - ✅ Output zeigt: "X Workflows geprüft, Y aktualisiert"
   - ✅ Keine Fehler

---

## Was sollte passieren?

### Bei erfolgreichem Backup:

1. **GitHub Commit:**
   - Commit-Message: `🤖 Workflow-Backup: [Workflow-Name] (update)` oder `(create)`
   - Datei wird in `n8n/{workflowId}/{workflowName}.json` gespeichert

2. **Lokal (nach Git Pull):**
   - Neue Datei/Ordner in `n8n/` Verzeichnis
   - Git-Log zeigt Backup-Commit

3. **n8n Execution:**
   - Status: Success
   - Output zeigt Statistik

---

## Troubleshooting

### Problem: Backup läuft nicht automatisch

**Prüfen:**
- Ist der Workflow aktiviert? (Toggle oben rechts)
- Ist der Schedule-Trigger konfiguriert? (`*/15 7-20 * * *` = alle 15 Min zwischen 7-20 Uhr)
- Wurde der Workflow manuell ausgeführt?

**Lösung:**
- Workflow aktivieren
- Oder manuell ausführen: "Execute Workflow" klicken

### Problem: Workflow wird nicht gespeichert

**Prüfen:**
- GitHub Credentials korrekt?
- Workflow-ID vorhanden?
- Workflow nicht archiviert?

**Lösung:**
- GitHub Token prüfen
- Workflow-ID prüfen (`workflow.id` muss vorhanden sein)
- Archivierte Workflows werden übersprungen

### Problem: Falsche Struktur

**Prüfen:**
- Wird in `n8n/{workflowId}/` gespeichert?
- Oder noch in alter Struktur `n8n/workflow-name.json`?

**Lösung:**
- Backup-Workflow prüfen: Node "Extrahieren und Verarbeiten"
- Sollte `aktueller_pfad = n8n/${workflowId}/${cleanName}.json` verwenden

---

## Manuelles Backup testen

Falls du ein manuelles Backup testen möchtest:

1. Öffne den Backup-Workflow in n8n
2. Klicke auf "Execute Workflow"
3. Warte auf Abschluss
4. Prüfe Execution-Output
5. Prüfe auf GitHub, ob Commit erstellt wurde

---

## ✅ Checkliste

- [ ] Backup-Workflow ist aktiviert
- [ ] Workflow wurde ausgeführt (manuell oder automatisch)
- [ ] Execution zeigt "Success"
- [ ] GitHub zeigt neuen Commit mit Backup-Message
- [ ] Datei ist in `n8n/{workflowId}/` Struktur gespeichert
- [ ] Lokal: `git pull` zeigt neue Dateien

