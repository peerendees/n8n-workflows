# 🔧 Fieckscher Feger - Technische Implementierung

## Schritt-für-Schritt Anleitung zur Optimierung

---

## 📋 Voraussetzungen

### Software & Accounts
- [ ] n8n installiert und läuft
- [ ] Supabase Account mit Zugriff
- [ ] Google Sheets API aktiviert
- [ ] Anthropic API (Claude) aktiv
- [ ] SerpAPI Account (Paid Plan empfohlen!)

### API-Limits prüfen

**Anthropic Claude:**
```bash
# Prüfe deinen Tier-Status auf: https://console.anthropic.com/settings/limits
# Tier 1: 50 requests/minute (ausreichend mit Rate Limiter)
# Tier 2: 1000 requests/minute (optimal)
```

**SerpAPI:**
```bash
# Prüfe deinen Plan auf: https://serpapi.com/dashboard
# Free: 100 Searches/Monat ❌ (NICHT ausreichend!)
# Starter ($50/mo): 5,000 Searches ✅
# Professional ($200/mo): 25,000 Searches ✅
```

---

## 🗄️ Phase 1: Supabase-Datenbank erweitern

### Schritt 1.1: Erweitere die bestehende Tabelle

```sql
-- Füge neue Spalten zur fieckscher_feger Tabelle hinzu
ALTER TABLE fieckscher_feger 
ADD COLUMN IF NOT EXISTS batch_id TEXT,
ADD COLUMN IF NOT EXISTS batch_number INTEGER,
ADD COLUMN IF NOT EXISTS processing_timestamp TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS retry_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'success';

-- Erstelle Indizes für bessere Performance
CREATE INDEX IF NOT EXISTS idx_investor_id ON fieckscher_feger(investor_id);
CREATE INDEX IF NOT EXISTS idx_batch_id ON fieckscher_feger(batch_id);
CREATE INDEX IF NOT EXISTS idx_status ON fieckscher_feger(status);
CREATE INDEX IF NOT EXISTS idx_processing_timestamp ON fieckscher_feger(processing_timestamp);
```

### Schritt 1.2: Erstelle Monitoring-Tabelle

```sql
-- Neue Tabelle für Batch-Monitoring
CREATE TABLE IF NOT EXISTS batch_monitoring (
    id SERIAL PRIMARY KEY,
    batch_id TEXT UNIQUE NOT NULL,
    batch_number INTEGER NOT NULL,
    investors_processed INTEGER DEFAULT 0,
    investors_successful INTEGER DEFAULT 0,
    investors_failed INTEGER DEFAULT 0,
    total_cost_usd NUMERIC(10,6) DEFAULT 0,
    avg_cost_per_investor NUMERIC(10,6),
    avg_processing_time_sec NUMERIC(10,2),
    success_rate NUMERIC(5,2),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status TEXT DEFAULT 'running',
    error_details JSONB,
    CONSTRAINT valid_batch_number CHECK (batch_number > 0)
);

-- Index für schnelle Abfragen
CREATE INDEX IF NOT EXISTS idx_batch_monitoring_status ON batch_monitoring(status);
CREATE INDEX IF NOT EXISTS idx_batch_monitoring_started ON batch_monitoring(started_at);
```

### Schritt 1.3: Erstelle Error-Log Tabelle

```sql
-- Tabelle für fehlgeschlagene Investoren
CREATE TABLE IF NOT EXISTS investor_errors (
    id SERIAL PRIMARY KEY,
    batch_id TEXT,
    investor_id TEXT NOT NULL,
    investor_name TEXT,
    error_type TEXT,
    error_message TEXT,
    error_details JSONB,
    retry_count INTEGER DEFAULT 0,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    resolved BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_investor_errors_resolved ON investor_errors(resolved);
CREATE INDEX IF NOT EXISTS idx_investor_errors_investor_id ON investor_errors(investor_id);
```

---

## 🔧 Phase 2: Workflow-Optimierungen

### Schritt 2.1: KRITISCH - Node 6 implementieren

**Problem:** Node 6 ist aktuell leer!

**Lösung:** Öffne den Workflow in n8n und füge folgenden Code in Node 6 ein:

```javascript
// Node 6: Daten für Excel vorbereiten
const items = $input.all();

// Prüfe ob Daten vorhanden sind
if (!items || items.length === 0) {
  return [];
}

// Gruppiere nach Investor
const investorGroups = {};

for (const item of items) {
  const investorId = item.json.investor_id;
  const investorName = item.json.investor_name;
  
  if (!investorGroups[investorId]) {
    investorGroups[investorId] = {
      investor_id: investorId,
      investor_name: investorName,
      batch_id: item.json.batch_id || '',
      batch_number: item.json.batch_number || 0,
      llm_cost_usd: item.json.llm_cost_usd || 0,
      criteria: [],
      total_score: 0,
      count_scores: 0
    };
  }
  
  // Sammle Kriterien
  investorGroups[investorId].criteria.push({
    name: item.json.criterion_name,
    score: item.json.score,
    source_type: item.json.source_type,
    source_year: item.json.source_year,
    source_factor: item.json.source_factor,
    notes: item.json.notes
  });
  
  // Summiere Scores (nur wenn nicht null)
  if (item.json.score !== null && item.json.score !== undefined) {
    investorGroups[investorId].total_score += item.json.score;
    investorGroups[investorId].count_scores += 1;
  }
}

// Erstelle Output für Google Sheet
const output = [];

Object.values(investorGroups).forEach(group => {
  // Berechne Durchschnitts-Score
  const avgScore = group.count_scores > 0 
    ? (group.total_score / group.count_scores).toFixed(3)
    : null;
  
  // Erstelle eine Zeile pro Kriterium (für detailliertes Sheet)
  group.criteria.forEach(criterion => {
    output.push({
      'Batch ID': group.batch_id,
      'Batch Number': group.batch_number,
      'Investor ID': group.investor_id,
      'Investor Name': group.investor_name,
      'Criterion': criterion.name,
      'Score': criterion.score !== null ? criterion.score : '',
      'Source Type': criterion.source_type || '',
      'Source Year': criterion.source_year || '',
      'Source Factor': criterion.source_factor || '',
      'Notes': criterion.notes || '',
      'Average Score': avgScore,
      'Cost USD': group.llm_cost_usd,
      'Timestamp': new Date().toISOString()
    });
  });
});

return output;
```

### Schritt 2.2: Node 2 anpassen (Batch-Größe)

**Aktueller Wert:**
```json
"batchSize": 1
```

**Für Tests (10 Investoren):**
```json
"batchSize": 10
```

**Für Produktion (100 Investoren):**
```json
"batchSize": 100
```

**So änderst du es in n8n:**
1. Öffne Node "2. Split In Batches (Prototyp)"
2. Ändere "Batch Size" auf gewünschten Wert
3. Speichere Workflow

### Schritt 2.3: Rate Limiter hinzufügen

**Neuer Node zwischen "Split In Batches" und "AI Agent":**

1. Klicke auf "+" zwischen Node 2 und Node 3
2. Suche nach "Wait"
3. Füge Node "Wait" ein
4. Konfiguration:
   - **Wait Time**: 2 seconds
   - **Resume On**: "After specified time has passed"

**Alternativ: Code für Rate Limiter:**
```javascript
// Alternative: Dynamischer Rate Limiter als Code-Node
const batchIndex = $node["2. Split In Batches (Prototyp)"].context.batchIndex || 0;
const itemsPerBatch = 100;

// Berechne Position im aktuellen Batch
const positionInBatch = batchIndex % itemsPerBatch;

// Pause alle 10 Investoren für 5 Sekunden
if (positionInBatch > 0 && positionInBatch % 10 === 0) {
  await new Promise(resolve => setTimeout(resolve, 5000));
  console.log(`Rate Limiter: 5s Pause nach ${positionInBatch} Investoren`);
}

// Kurze Pause zwischen jedem Request
await new Promise(resolve => setTimeout(resolve, 2000));

return $input.all();
```

### Schritt 2.4: Error Handler hinzufügen

**Neuer Node nach "AI Agent" (vor Node 4):**

1. Füge Code-Node "Error Handler" ein
2. Code:

```javascript
// Error Handler für AI Agent Fehler
try {
  const input = $input.all();
  
  // Prüfe ob AI Agent erfolgreich war
  if (!input || input.length === 0) {
    throw new Error('Keine Daten vom AI Agent erhalten');
  }
  
  const item = input[0].json;
  
  // Prüfe ob LLM Output vorhanden
  if (!item.llmAgent || !item.llmAgent.output) {
    throw new Error('LLM Agent hat keinen Output generiert');
  }
  
  // Prüfe ob Output eine Tabelle enthält
  const output = item.llmAgent.output;
  if (!output.includes('|') || output.split('\n').length < 3) {
    throw new Error('LLM Output enthält keine gültige Markdown-Tabelle');
  }
  
  // Alles OK, leite weiter
  return input;
  
} catch (error) {
  // Fehler aufgetreten - logge in separatem Output
  const investorId = $json.ID || 'unknown';
  const investorName = $json['Investor Name'] || $json.Investor || 'unknown';
  
  console.error(`Fehler bei Investor ${investorId}: ${error.message}`);
  
  // Erstelle Error-Objekt für Supabase
  return [{
    json: {
      investor_id: investorId,
      investor_name: investorName,
      error_type: error.name || 'UnknownError',
      error_message: error.message,
      error_details: {
        raw_input: $json,
        timestamp: new Date().toISOString(),
        node: 'AI Agent',
        execution_id: $execution.id
      },
      retry_count: 0,
      timestamp: new Date().toISOString(),
      status: 'failed'
    }
  }];
}
```

### Schritt 2.5: Duplikat-Check hinzufügen

**Neuer Node nach "Get row(s) in sheet" (vor "Split In Batches"):**

1. Füge "Supabase" Node ein (Type: "Get All")
2. Name: "Check Existing Investors"
3. Konfiguration:
   - Operation: "Get All"
   - Table: `fieckscher_feger`

4. Danach: Code-Node "Filter New Investors"

```javascript
// Filter: Nur neue Investoren verarbeiten
const sheetInvestors = $('Get row(s) in sheet').all();
const existingInvestors = $('Check Existing Investors').all();

// Erstelle Set der bereits verarbeiteten Investor-IDs
const processedIds = new Set(
  existingInvestors.map(item => item.json.investor_id)
);

// Filtere neue Investoren
const newInvestors = sheetInvestors.filter(item => {
  const investorId = item.json.ID;
  const isProcessed = processedIds.has(investorId);
  
  if (isProcessed) {
    console.log(`Überspringe Investor ${investorId} - bereits verarbeitet`);
  }
  
  return !isProcessed;
});

console.log(`Gefiltert: ${newInvestors.length} neue von ${sheetInvestors.length} gesamt`);

return newInvestors;
```

### Schritt 2.6: Batch-Monitoring hinzufügen

**Neuer Node am Ende (nach "Google Sheet schreiben"):**

1. Füge Code-Node "Calculate Batch Stats" ein
2. Code:

```javascript
// Batch-Statistiken berechnen
const allItems = $('5. Supabase: Zwischenspeicher (Log)').all();
const batchId = $execution.id;

// Gruppiere nach Investor
const investors = {};
allItems.forEach(item => {
  const id = item.json.investor_id;
  if (!investors[id]) {
    investors[id] = {
      id: id,
      cost: item.json.llm_cost_usd || 0,
      status: item.json.status || 'success'
    };
  }
});

const investorArray = Object.values(investors);

// Berechne Statistiken
const totalProcessed = investorArray.length;
const totalSuccessful = investorArray.filter(i => i.status === 'success').length;
const totalFailed = totalProcessed - totalSuccessful;
const totalCost = investorArray.reduce((sum, i) => sum + i.cost, 0);
const avgCost = totalProcessed > 0 ? totalCost / totalProcessed : 0;
const successRate = totalProcessed > 0 ? (totalSuccessful / totalProcessed) * 100 : 0;

// Batch-Nummer aus Context (falls verfügbar)
const splitNode = $node["2. Split In Batches (Prototyp)"];
const batchNumber = splitNode?.context?.batchNumber || 1;

return [{
  json: {
    batch_id: batchId,
    batch_number: batchNumber,
    investors_processed: totalProcessed,
    investors_successful: totalSuccessful,
    investors_failed: totalFailed,
    total_cost_usd: parseFloat(totalCost.toFixed(6)),
    avg_cost_per_investor: parseFloat(avgCost.toFixed(6)),
    success_rate: parseFloat(successRate.toFixed(2)),
    completed_at: new Date().toISOString(),
    status: 'completed'
  }
}];
```

3. Danach: Supabase Node "Save Batch Stats"
   - Operation: "Insert"
   - Table: `batch_monitoring`

---

## 🧪 Phase 3: Test-Szenarien

### Test 1: Mini-Test (1 Investor)

**Ziel:** Grundfunktionalität prüfen

**Setup:**
```json
// Node 2: Split In Batches
"batchSize": 1

// Google Sheet: Limitiere auf 1 Zeile
// oder erstelle Test-Sheet mit nur 1 Investor
```

**Durchführung:**
1. Öffne Workflow in n8n
2. Klicke "Execute Workflow"
3. Warte ~30 Sekunden
4. Prüfe alle Node-Outputs

**Checkliste:**
- [ ] AI Agent liefert Markdown-Tabelle
- [ ] 9 Kriterien werden erkannt
- [ ] Kosten werden berechnet
- [ ] Supabase-Eintrag erfolgreich
- [ ] Google Sheet wird aktualisiert

**Erwartete Kosten:** ~$0.20-0.40

### Test 2: Klein-Test (10 Investoren)

**Ziel:** Batch-Verarbeitung & Performance testen

**Setup:**
```json
// Node 2: Split In Batches
"batchSize": 10
```

**Durchführung:**
1. Backup deines Google Sheets erstellen!
2. Workflow starten
3. Monitoring aktiv beobachten
4. Nach Abschluss: Daten validieren

**Messpunkte:**
- Gesamtdauer: ___ Minuten (erwartet: 3-5 Min)
- Gesamtkosten: $____ (erwartet: $2-4)
- Fehlerrate: ___% (erwartet: < 10%)
- Durchschnitt/Investor: ___ Sekunden

**Validierung:**
```sql
-- Prüfe in Supabase
SELECT 
    COUNT(DISTINCT investor_id) as investors,
    AVG(llm_cost_usd) as avg_cost,
    SUM(llm_cost_usd) as total_cost,
    COUNT(*) / COUNT(DISTINCT investor_id) as criteria_per_investor
FROM fieckscher_feger
WHERE processing_timestamp > NOW() - INTERVAL '10 minutes';

-- Erwartetes Ergebnis:
-- investors: 10
-- avg_cost: ~0.30
-- total_cost: ~3.00
-- criteria_per_investor: 9
```

### Test 3: Medium-Test (100 Investoren)

**Ziel:** Produktions-Readiness prüfen

**Setup:**
```json
// Node 2: Split In Batches
"batchSize": 100
```

**Vor dem Test:**
- [ ] SerpAPI Paid Plan aktiv
- [ ] Budget-Alert gesetzt ($50)
- [ ] Monitoring-Dashboard offen
- [ ] Backup erstellt

**Durchführung:**
1. Workflow starten
2. Alle 5 Minuten: Monitoring checken
3. Nach 20 Investoren: Stichprobe Datenqualität
4. Nach 50 Investoren: Kosten-Check
5. Nach Abschluss: Vollständige Analyse

**Monitoring während Test:**

```sql
-- Live-Query (alle 2 Minuten ausführen)
SELECT 
    COUNT(DISTINCT investor_id) as processed,
    COUNT(DISTINCT investor_id) FILTER (WHERE status = 'success') as successful,
    COUNT(DISTINCT investor_id) FILTER (WHERE status = 'failed') as failed,
    SUM(llm_cost_usd) as cost_so_far,
    (SUM(llm_cost_usd) / COUNT(DISTINCT investor_id)) * 2000 as projected_total
FROM fieckscher_feger
WHERE processing_timestamp > NOW() - INTERVAL '30 minutes';
```

**Erwartete Werte nach 100 Investoren:**
- Dauer: 10-15 Minuten
- Kosten: $30-40
- Erfolgsrate: > 95%
- Fehler: < 5 Investoren

**Bei Problemen:**
- Fehlerrate > 10%: Workflow stoppen, Fehler analysieren
- Kosten > $50: Workflow stoppen, Kosten-Optimierung
- Dauer > 20 Min: Rate Limiter anpassen

---

## 🚀 Phase 4: Produktiv-Durchlauf (2000 Investoren)

### Pre-Flight Checklist

**Technisch:**
- [ ] Alle Tests erfolgreich (10er + 100er)
- [ ] Node 6 implementiert und getestet
- [ ] Duplikat-Check funktioniert
- [ ] Error Handler getestet
- [ ] Rate Limiter aktiv (2-5s)
- [ ] Batch-Monitoring läuft

**Datenbank:**
- [ ] Supabase-Tabellen erweitert
- [ ] Indizes erstellt
- [ ] Monitoring-Queries getestet

**APIs:**
- [ ] SerpAPI Paid Plan aktiv (min. $50/Monat)
- [ ] Claude API Tier geprüft
- [ ] Budget-Alerts gesetzt

**Backup:**
- [ ] Google Sheet Backup erstellt
- [ ] Supabase Backup erstellt (falls vorhanden)

### Durchführung

**Setup:**
```json
// Node 2: Split In Batches
"batchSize": 100
```

**Zeitplan:**
- **Start:** Am besten außerhalb Geschäftszeiten
- **Dauer:** 1-2 Stunden
- **Monitoring:** Erste 30 Minuten aktiv beobachten

**Batch-Fortschritt:**
```
Batch 1-5 (500 Investoren):   30-45 Min → Aktives Monitoring
Batch 6-10 (500 Investoren):  30-45 Min → Stichproben
Batch 11-15 (500 Investoren): 30-45 Min → Stichproben
Batch 16-20 (500 Investoren): 30-45 Min → Final Check
```

### Live-Monitoring

**Dashboard-Queries (alle 10 Minuten):**

```sql
-- 1. Fortschritt
SELECT 
    COUNT(DISTINCT investor_id) as processed,
    ROUND(COUNT(DISTINCT investor_id) * 100.0 / 2000, 1) as progress_percent,
    '~' || ROUND((2000 - COUNT(DISTINCT investor_id)) * 3 / 60.0) || ' Min remaining' as estimated_remaining
FROM fieckscher_feger
WHERE processing_timestamp > NOW() - INTERVAL '3 hours';

-- 2. Kosten
SELECT 
    SUM(llm_cost_usd) as spent_so_far,
    AVG(llm_cost_usd) as avg_per_investor,
    ROUND((AVG(llm_cost_usd) * 2000)::numeric, 2) as projected_total
FROM fieckscher_feger
WHERE processing_timestamp > NOW() - INTERVAL '3 hours';

-- 3. Fehlerrate
SELECT 
    status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentage
FROM fieckscher_feger
WHERE processing_timestamp > NOW() - INTERVAL '3 hours'
GROUP BY status;

-- 4. Letzte 10 verarbeitete Investoren
SELECT 
    investor_name,
    status,
    llm_cost_usd,
    TO_CHAR(processing_timestamp, 'HH24:MI:SS') as time
FROM fieckscher_feger
WHERE processing_timestamp > NOW() - INTERVAL '3 hours'
ORDER BY processing_timestamp DESC
LIMIT 10;
```

### Notfall-Abbruch

**Bei kritischen Problemen:**
1. Workflow in n8n stoppen (Stop Execution)
2. Aktuelle Position prüfen:

```sql
SELECT MAX(batch_number) as last_completed_batch
FROM batch_monitoring
WHERE status = 'completed';
```

3. Fehleranalyse:

```sql
SELECT 
    error_type,
    COUNT(*) as error_count,
    array_agg(DISTINCT investor_name) as affected_investors
FROM investor_errors
WHERE timestamp > NOW() - INTERVAL '3 hours'
GROUP BY error_type
ORDER BY error_count DESC;
```

### Resume nach Abbruch

1. Prüfe letzte Batch-Nummer:
```sql
SELECT MAX(batch_number) FROM batch_monitoring WHERE status = 'completed';
```

2. Filtere bereits verarbeitete Investoren (Duplikat-Check macht das automatisch!)

3. Workflow neu starten

---

## 📊 Phase 5: Post-Processing & Validierung

### Datenqualitäts-Check

```sql
-- 1. Vollständigkeit
SELECT 
    COUNT(DISTINCT investor_id) as total_investors,
    COUNT(DISTINCT investor_id) FILTER (
        WHERE (
            SELECT COUNT(*) 
            FROM fieckscher_feger f2 
            WHERE f2.investor_id = f1.investor_id
        ) = 9
    ) as investors_with_all_criteria,
    ROUND(
        COUNT(DISTINCT investor_id) FILTER (
            WHERE (SELECT COUNT(*) FROM fieckscher_feger f2 WHERE f2.investor_id = f1.investor_id) = 9
        ) * 100.0 / COUNT(DISTINCT investor_id), 
        1
    ) as completeness_percent
FROM fieckscher_feger f1;

-- 2. Score-Verteilung
SELECT 
    criterion_name,
    COUNT(*) as total,
    COUNT(score) as with_score,
    ROUND(AVG(score)::numeric, 2) as avg_score,
    MIN(score) as min_score,
    MAX(score) as max_score
FROM fieckscher_feger
GROUP BY criterion_name
ORDER BY criterion_name;

-- 3. Top 20 Investoren nach Durchschnitts-Score
SELECT 
    investor_name,
    ROUND(AVG(score)::numeric, 3) as avg_score,
    COUNT(*) as criteria_count,
    SUM(llm_cost_usd) as cost
FROM fieckscher_feger
WHERE score IS NOT NULL
GROUP BY investor_id, investor_name
HAVING COUNT(*) >= 7  -- mindestens 7 von 9 Kriterien
ORDER BY avg_score DESC
LIMIT 20;
```

### Final Report

**Excel-Export aus Supabase:**

```sql
-- Export für Auftraggeber
SELECT 
    investor_name as "Investor",
    criterion_name as "Kriterium",
    COALESCE(score::text, 'Keine Info') as "Score (0-1)",
    source_type as "Quelle-Typ",
    source_year as "Jahr",
    notes as "Notizen & URL",
    TO_CHAR(processing_timestamp, 'DD.MM.YYYY HH24:MI') as "Verarbeitet am"
FROM fieckscher_feger
ORDER BY investor_name, criterion_name;
```

**Kosten-Report:**

```sql
SELECT 
    SUM(total_cost_usd) as gesamtkosten,
    AVG(avg_cost_per_investor) as durchschnitt_pro_investor,
    SUM(investors_processed) as investoren_gesamt,
    AVG(success_rate) as durchschnittliche_erfolgsrate,
    MAX(completed_at) - MIN(started_at) as gesamtdauer
FROM batch_monitoring;
```

---

## 🔍 Troubleshooting

### Problem: "API Rate Limit Exceeded"

**Symptom:** Fehler bei AI Agent nach ~50 Requests

**Lösung:**
1. Erhöhe Rate Limiter von 2s auf 5s
2. Prüfe Anthropic Tier:
   ```
   Tier 1: 50 req/min → max 1 req/1.2s
   Tier 2: 1000 req/min → OK
   ```

### Problem: "SerpAPI Budget Exhausted"

**Symptom:** Fehler "Insufficient credits"

**Lösung:**
1. Upgrade auf Paid Plan
2. Oder: Reduziere Suchanfragen im Prompt

### Problem: Node 6 schreibt nichts ins Google Sheet

**Symptom:** Supabase OK, aber Google Sheet leer

**Debug:**
1. Prüfe Output von Node 6:
   ```javascript
   console.log('Node 6 Output:', JSON.stringify($input.all(), null, 2));
   ```
2. Prüfe Google Sheet Permissions
3. Prüfe Column Mapping in Node 7

### Problem: Workflow stoppt nach 50 Investoren

**Symptom:** Workflow "hängt" oder bricht ab

**Mögliche Ursachen:**
1. **n8n Timeout:** Erhöhe Execution Timeout in n8n Settings
2. **Memory:** n8n läuft aus Speicher → Reduziere Batch Size
3. **API Timeout:** Rate Limiter zu kurz

**Debug:**
```sql
-- Prüfe letzte erfolgreiche Verarbeitung
SELECT 
    investor_name,
    processing_timestamp,
    status
FROM fieckscher_feger
ORDER BY processing_timestamp DESC
LIMIT 5;
```

---

## 📚 Nützliche SQL-Queries

### Quick Stats

```sql
-- Dashboard: Aktuelle Statistiken
SELECT 
    'Investoren gesamt' as metrik, COUNT(DISTINCT investor_id)::text as wert
FROM fieckscher_feger
UNION ALL
SELECT 
    'Einträge gesamt', COUNT(*)::text
FROM fieckscher_feger
UNION ALL
SELECT 
    'Durchschn. Score', ROUND(AVG(score)::numeric, 2)::text
FROM fieckscher_feger
WHERE score IS NOT NULL
UNION ALL
SELECT 
    'Gesamtkosten USD', '$' || ROUND(SUM(llm_cost_usd)::numeric, 2)::text
FROM fieckscher_feger
UNION ALL
SELECT 
    'Fehlerrate %', ROUND(
        COUNT(*) FILTER (WHERE status = 'failed') * 100.0 / COUNT(*), 
        1
    )::text
FROM fieckscher_feger;
```

### Investoren ohne vollständige Daten

```sql
-- Finde Investoren mit weniger als 9 Kriterien
SELECT 
    investor_id,
    investor_name,
    COUNT(*) as criteria_count,
    array_agg(criterion_name ORDER BY criterion_name) as existing_criteria
FROM fieckscher_feger
GROUP BY investor_id, investor_name
HAVING COUNT(*) < 9
ORDER BY criteria_count, investor_name;
```

### Kosten pro Kriterium

```sql
-- Durchschnittskosten aufgeschlüsselt
SELECT 
    criterion_name,
    COUNT(*) as anzahl,
    AVG(llm_cost_usd) as avg_cost,
    SUM(llm_cost_usd) as total_cost
FROM fieckscher_feger
GROUP BY criterion_name
ORDER BY total_cost DESC;
```

---

## ✅ Checkliste: Bereit für 2000 Investoren

**Vor dem Start:**
- [ ] Node 6 Code eingefügt und getestet
- [ ] Batch Size auf 100 gesetzt
- [ ] Rate Limiter aktiv (2-5 Sekunden)
- [ ] Duplikat-Check eingebaut
- [ ] Error Handler implementiert
- [ ] Batch-Monitoring funktioniert
- [ ] Supabase-Tabellen erweitert
- [ ] SerpAPI Paid Plan aktiv ($50+)
- [ ] Budget-Alerts gesetzt
- [ ] Google Sheet Backup erstellt
- [ ] 10er-Test erfolgreich
- [ ] 100er-Test erfolgreich
- [ ] Monitoring-Queries vorbereitet
- [ ] Zeitfenster von 2 Stunden reserviert

**Während des Laufs:**
- [ ] Monitoring alle 10 Minuten
- [ ] Stichproben nach Batch 5, 10, 15
- [ ] Kosten-Check nach 500 Investoren

**Nach Abschluss:**
- [ ] Datenqualitäts-Check durchführen
- [ ] Final Report erstellen
- [ ] Export für Auftraggeber
- [ ] Lessons Learned dokumentieren

---

## 🎯 Erwartete Ergebnisse

Nach erfolgreichem Durchlauf:

- ✅ ~2000 Investoren vollständig recherchiert
- ✅ ~18.000 Datenpunkte (9 Kriterien × 2000)
- ✅ Kosten: $400-600
- ✅ Dauer: 1-2 Stunden
- ✅ Erfolgsrate: > 95%
- ✅ Datenqualität: > 90% vollständig

---

**Version:** 1.0  
**Stand:** {{CURRENT_DATE}}  
**Status:** Ready for Implementation

---

## 📞 Support

Bei Fragen oder Problemen:
1. Prüfe Troubleshooting-Sektion
2. Checke n8n Community Forum
3. Review Anthropic/SerpAPI Dokumentation
4. Debug mit SQL-Queries aus diesem Dokument

