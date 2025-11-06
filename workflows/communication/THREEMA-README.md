# Threema n8n Workflows

Umfassende n8n-Workflows für die Integration von Threema Work und Threema Gateway in Ihre Automatisierungsprozesse.

## 📋 Verfügbare Workflows

### 1. Threema Gateway Universal (NEU)
**Datei:** `threema-gateway-universal.json`

Ein universeller Workflow für Threema Gateway, der alle Nachrichtentypen und Dateien verarbeitet.

#### Features:
- ✅ Empfang aller Nachrichtentypen (Text, Bilder, Audio, Video, Dokumente)
- ✅ Automatischer Download von Dateien
- ✅ Intelligente Dateityp-Erkennung
- ✅ Flexible Verarbeitungslogik
- ✅ Automatische Bestätigung an Sender
- ✅ Vollständige Fehlerbehandlung

#### Verwendung:
Dieser Workflow dient als Basis-Template für Ihre Threema Gateway Integration. Sie können die Verarbeitung im Node "Nachricht verarbeiten" anpassen.

---

### 2. Threema Work Voice Transcription
**Datei:** `threema-work-workflow.json`

Webhook-basierter Workflow für Sprachnachrichten mit OpenAI Whisper Transkription.

#### Features:
- ✅ Webhook-Empfang von Threema Work Nachrichten
- ✅ Audio-Datei Download
- ✅ Automatische Transkription mit OpenAI Whisper
- ✅ Weiterleitung an berent.ai API
- ✅ Erfolgs-/Fehler-Benachrichtigungen
- ✅ E-Mail-Benachrichtigung bei Fehlern

---

### 3. Threema Work Polling Voice Transcription
**Datei:** `threema-work-polling-workflow.json`

Polling-basierter Workflow für Sprachnachrichten (Alternative zum Webhook).

#### Features:
- ✅ Polling alle 2 Minuten
- ✅ Automatische Nachrichtenabfrage
- ✅ Audio-Transkription
- ✅ Batch-Verarbeitung mehrerer Nachrichten
- ✅ Ideal wenn keine Webhooks möglich sind

---

## 🔧 Einrichtung

### Voraussetzungen

#### Für Threema Gateway:
1. Threema Gateway Konto (https://gateway.threema.ch)
2. Gateway-ID und Secret
3. API-Zugang aktiviert

#### Für Threema Work:
1. Threema Work Lizenz
2. Threema Work API-Key
3. Webhook-URL oder Polling-Berechtigung

### Schritt 1: Credentials in n8n anlegen

#### Threema Gateway API:
1. Gehen Sie zu **Credentials** > **New**
2. Wählen Sie **HTTP Header Auth**
3. Konfiguration:
   - Name: `Threema Gateway API`
   - Header Name: `Authorization` (optional)
   - Header Value: Ihr Secret (oder leer lassen und im Workflow als Query-Parameter nutzen)

#### Threema Work API:
1. Gehen Sie zu **Credentials** > **New**
2. Wählen Sie **HTTP Header Auth**
3. Konfiguration:
   - Name: `Threema Work API`
   - Header Name: `X-API-Key`
   - Header Value: Ihr Threema Work API-Key

### Schritt 2: Workflow importieren

1. Öffnen Sie n8n
2. Klicken Sie auf **Workflows** > **Import from File**
3. Wählen Sie die gewünschte JSON-Datei
4. Workflow öffnet sich automatisch

### Schritt 3: Credentials zuweisen

1. Öffnen Sie jeden Node mit einem roten Ausrufezeichen
2. Wählen Sie die entsprechende Credential aus
3. Speichern Sie den Node

### Schritt 4: Webhook-URL konfigurieren (für Webhook-basierte Workflows)

1. Öffnen Sie den Webhook-Node
2. Kopieren Sie die **Production URL**
3. Beispiel: `https://ihr-n8n-server.com/webhook/threema-gateway`
4. Konfigurieren Sie diese URL in Ihrem Threema Gateway/Work Portal

### Schritt 5: Workflow aktivieren

1. Klicken Sie oben rechts auf **Active**
2. Der Workflow ist jetzt live und empfängt Nachrichten

---

## 🎯 Anpassungsmöglichkeiten

### Threema Gateway Universal - Verarbeitung anpassen

Der Node **"Nachricht verarbeiten"** ist Ihr zentraler Verarbeitungspunkt. Hier einige Beispiele:

#### Beispiel 1: Nachrichten in Google Drive speichern
```javascript
// Im Node "Nachricht verarbeiten" einfügen:
// Dann Google Drive Node hinzufügen

if (item.hasFile && item.fileCategory === 'document') {
  // Datei ist bereit für Google Drive Upload
  return {
    json: {
      ...item,
      saveToGoogleDrive: true
    },
    binary: $input.item.binary
  };
}
```

#### Beispiel 2: Text-Nachrichten analysieren mit OpenAI
```javascript
// Im Node "Nachricht verarbeiten" einfügen:
// Dann OpenAI Node hinzufügen

if (item.text && !item.hasFile) {
  return {
    json: {
      ...item,
      analyzeWithAI: true,
      prompt: `Analysiere folgende Nachricht: ${item.text}`
    }
  };
}
```

#### Beispiel 3: Bilder mit Bilderkennung verarbeiten
```javascript
// Im Node "Nachricht verarbeiten" einfügen:
// Dann Vision API Node hinzufügen

if (item.hasFile && item.fileCategory === 'image') {
  return {
    json: {
      ...item,
      processWithVision: true
    },
    binary: $input.item.binary
  };
}
```

### Zusätzliche Nodes hinzufügen

Nach dem Node "Nachricht verarbeiten" können Sie beliebige n8n-Nodes hinzufügen:

- **Google Drive/Dropbox**: Dateien speichern
- **OpenAI/Claude**: KI-Verarbeitung
- **PostgreSQL/MySQL**: Datenbank-Speicherung
- **Slack/Discord**: Benachrichtigungen
- **Airtable/Notion**: CRM/Dokumentation
- **Email Send**: E-Mail-Benachrichtigungen

---

## 🔐 Sicherheitshinweise

1. **Credentials sicher speichern**: Nutzen Sie n8n's Credential-System
2. **Webhook-URL schützen**: Nutzen Sie HTTPS und optional Authentication
3. **API-Limits beachten**: Threema Gateway hat Rate-Limits
4. **Datenschutz**: Verarbeiten Sie sensible Daten DSGVO-konform
5. **Logging**: Aktivieren Sie Logging für Debugging, aber loggen Sie keine Credentials

---

## 📊 Monitoring & Debugging

### Workflow-Ausführungen prüfen
1. Gehen Sie zu **Executions**
2. Sehen Sie alle Workflow-Ausführungen
3. Klicken Sie auf eine Ausführung für Details

### Häufige Probleme

#### Problem: Webhook empfängt keine Daten
**Lösung:**
- Prüfen Sie die Webhook-URL in Threema
- Stellen Sie sicher, dass n8n von außen erreichbar ist
- Prüfen Sie Firewall-Einstellungen

#### Problem: Datei-Download schlägt fehl
**Lösung:**
- Prüfen Sie die Threema Gateway Credentials
- Stellen Sie sicher, dass die blob_id korrekt ist
- Prüfen Sie API-Limits

#### Problem: Bestätigung wird nicht gesendet
**Lösung:**
- Prüfen Sie die Gateway/Work API Credentials
- Stellen Sie sicher, dass die Absender-ID korrekt ist
- Prüfen Sie die API-Response im Execution Log

---

## 🌟 Erweiterte Funktionen

### Mehrsprachige Verarbeitung
Fügen Sie einen Language Detection Node hinzu:
```javascript
// Sprache erkennen
const languageDetection = {
  text: item.text,
  detectLanguage: true
};
```

### Intelligente Antworten
Fügen Sie einen AI Chat Node hinzu für automatische Antworten:
```javascript
// Automatische Antwort generieren
const aiResponse = {
  prompt: `Beantworte folgende Nachricht professionell: ${item.text}`,
  temperature: 0.7
};
```

### Datei-Konvertierung
Fügen Sie einen File Converter Node hinzu:
```javascript
// PDF zu Text konvertieren
if (item.mimeType === 'application/pdf') {
  // PDF Converter Node hinzufügen
}
```

---

## 📚 Weiterführende Ressourcen

### Threema Documentation
- Threema Gateway API: https://gateway.threema.ch/en/developer/api
- Threema Work API: https://work.threema.ch/en/api

### n8n Documentation
- n8n Workflows: https://docs.n8n.io/workflows/
- n8n Credentials: https://docs.n8n.io/credentials/
- n8n Expressions: https://docs.n8n.io/code-examples/expressions/

### Support
- Threema Support: support@threema.ch
- n8n Community: https://community.n8n.io/

---

## 📝 Best Practices

1. **Testen Sie zuerst im Development-Modus**
   - Nutzen Sie den "Test Workflow" Button
   - Senden Sie Test-Nachrichten

2. **Verwenden Sie aussagekräftige Namen**
   - Benennen Sie Nodes klar und deutlich
   - Nutzen Sie Sticky Notes für Dokumentation

3. **Implementieren Sie Error Handling**
   - Nutzen Sie "Continue On Fail"
   - Senden Sie Error-Benachrichtigungen

4. **Optimieren Sie Performance**
   - Vermeiden Sie unnötige API-Calls
   - Nutzen Sie Caching wo möglich

5. **Dokumentieren Sie Anpassungen**
   - Fügen Sie Kommentare in Code-Nodes hinzu
   - Aktualisieren Sie Sticky Notes

---

## 🤝 Contribution

Haben Sie Verbesserungen oder zusätzliche Workflows entwickelt?

1. Forken Sie das Repository
2. Erstellen Sie einen Feature-Branch
3. Committen Sie Ihre Änderungen
4. Erstellen Sie einen Pull Request

---

## 📄 Lizenz

Diese Workflows stehen unter der MIT-Lizenz zur freien Verwendung.

---

## ✉️ Kontakt

Bei Fragen oder Problemen:
- GitHub Issues: https://github.com/peerendees/n8n-workflows/issues
- E-Mail: Siehe Repository-Beschreibung

---

**Version:** 1.0
**Letzte Aktualisierung:** Januar 2025
**Kompatibilität:** n8n v1.0+
