# Migrations-Workflow Anleitung

## Übersicht

Der Migrations-Workflow migriert alle n8n Workflows von der alten Struktur (`n8n/workflow-name.json`) zur neuen Struktur (`n8n/{workflowId}/{workflowName}.json`).

## Features

- ✅ **Testmodus**: Teste die Migration mit einem einzelnen Workflow
- ✅ **Produktionsmodus**: Migriert alle Workflows auf einmal
- ✅ **Threema-Benachrichtigung**: Erhält eine Benachrichtigung nach erfolgreicher Migration
- ✅ **Automatische Fehlerbehandlung**: Überspringt archivierte Workflows

## Konfiguration

### Config-Node Einstellungen

Öffne den **"Config"** Node im Migrations-Workflow:

1. **`testModus`** (boolean):
   - `true` = Testmodus (nur ein Workflow wird migriert)
   - `false` = Produktionsmodus (alle Workflows werden migriert)

2. **`testWorkflowName`** (string):
   - Im Testmodus: Name des Workflows zum Testen (z.B. `"Hedy Webhook to Notion 0.9"`)
   - Im Produktionsmodus: Leer lassen (`""`)

3. **`threemaSecret`** (string):
   - Threema API Secret (bereits vorkonfiguriert)

## Verwendung

### Schritt 1: Test-Migration (empfohlen)

1. Öffne den Migrations-Workflow in n8n
2. Öffne den **"Config"** Node
3. Setze:
   - `testModus` = `true`
   - `testWorkflowName` = Name des Test-Workflows (z.B. `"Hedy Webhook to Notion 0.9"`)
4. Führe den Workflow aus (Execute Workflow)
5. Prüfe die Ergebnisse:
   - Execution History zeigt: "1 migriert, X übersprungen"
   - Auf GitHub prüfen: `n8n/{workflowId}/{workflowName}.json` existiert
   - Threema-Benachrichtigung erhalten (wenn Migration erfolgreich)

### Schritt 2: Produktions-Migration

**WICHTIG:** Nur ausführen, wenn Test-Migration erfolgreich war!

1. Öffne den **"Config"** Node erneut
2. Setze:
   - `testModus` = `false`
   - `testWorkflowName` = `""` (leer)
3. Führe den Workflow aus
4. Alle Workflows werden migriert
5. Prüfe die Ergebnisse:
   - Execution History zeigt: "X migriert, Y übersprungen"
   - Threema-Benachrichtigung mit vollständiger Statistik

## Beispiel-Nachrichten

### Test-Modus Nachricht:
```
🧪 TEST-MIGRATION abgeschlossen
Test-Workflow: Hedy Webhook to Notion 0.9
25 Workflows geprüft.
Ergebnis: 1 migriert, 24 übersprungen, 0 Fehler.

✅ Migriert: Hedy Webhook to Notion 0.9

🔗 https://github.com/peerendees/n8n-workflows/n8n
```

### Produktions-Modus Nachricht:
```
🔄 MIGRATION abgeschlossen: 25 Workflows geprüft.
Ergebnis: 20 migriert, 5 übersprungen, 0 Fehler.

✅ Migriert: Workflow 1
✅ Migriert: Workflow 2
...
✅ Migriert: Workflow 20

🔗 https://github.com/peerendees/n8n-workflows/n8n
```

## Was wird migriert?

- ✅ Alle aktiven Workflows (nicht archiviert)
- ✅ Von alter Struktur: `n8n/workflow-name.json`
- ✅ Zu neuer Struktur: `n8n/{workflowId}/{workflowName}.json`

## Was wird übersprungen?

- ❌ Archivierte Workflows (`isArchived === true`)
- ❌ Workflows, die bereits in neuer Struktur existieren
- ❌ Im Testmodus: Alle Workflows außer dem Test-Workflow

## Nach der Migration

1. ✅ Alle Workflows sind in der neuen Struktur
2. ✅ Backup-Workflow funktioniert jetzt korrekt
3. ✅ Alte Dateien bleiben vorerst erhalten (können später gelöscht werden)
4. ✅ Migrations-Workflow kann deaktiviert/archiviert werden

## Troubleshooting

### Workflow wird nicht migriert
- Prüfe, ob der Workflow archiviert ist
- Prüfe, ob der Workflow bereits in neuer Struktur existiert
- Prüfe die Execution History für Fehlermeldungen

### Threema-Benachrichtigung fehlt
- Prüfe, ob Migrationen durchgeführt wurden (`hasChanges === true`)
- Prüfe Threema-Credentials im Node
- Prüfe Execution History für Fehler

### Testmodus funktioniert nicht
- Prüfe, ob `testModus = true` gesetzt ist
- Prüfe, ob `testWorkflowName` exakt dem Workflow-Namen entspricht (Groß-/Kleinschreibung beachten!)
- Prüfe die Execution History

