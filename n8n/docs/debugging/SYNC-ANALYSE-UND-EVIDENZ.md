# GitHub → n8n Sync: Analyse, Evidenz und Root Cause

Dieses Dokument ergänzt [DEBUGGING-ANLEITUNG.md](DEBUGGING-ANLEITUNG.md) und führt die im Reparatur-Plan vorgesehenen Schritte **ohne** die Cursor-Plan-Datei zu duplizieren.

## 1. Feature-Branch vs. `main` und Backup-Reihenfolge nachvollziehen

### Was im Repo gilt

- Der Workflow [GitHub → n8n Synchronisation](../../499J5QUt4xUoTujR/GitHub%20→%20n8n%20Synchronisation.json) lädt Dateien von GitHub mit Referenz **`main`** (Node `Hole Datei von GitHub`).
- Änderungen nur auf einem Feature-Branch sind für n8n **unsichtbar**, bis sie auf `main` gemerged sind.

### Git-Historie lokal prüfen

Im geklonten Repository (Branch `main`):

```bash
git fetch origin
git log origin/main --oneline -30 -- "n8n/"
```

**Lesart:** Such nach aufeinanderfolgenden Commits derselben Pfade: ein Merge oder manueller Fix, kurz darauf ein Commit mit `Auto-Backup` im Text — dort kann die Race Condition sichtbar werden (Merge-Stand vs. Backup aus n8n).

Nur Feature-Branch (ohne Merge):

```bash
git branch -a
git log origin/<feature-branch> --oneline -10 -- "n8n/"
```

Solange kein Merge nach `main` erfolgt ist, triggert der Sync **keinen** Abgleich der neuen Logik in n8n (siehe [BEST_PRACTICES.md](../../../BEST_PRACTICES.md) §5).

---

## 2. Evidenz aus n8n sammeln (fehlgeschlagen oder „leer“)

Vorlage zum Ausfüllen bei einer problematischen Execution:

| Feld | Inhalt |
|------|--------|
| Execution-ID | |
| Zeitpunkt (UTC/DE) | |
| Auslöser | Push auf `main` / anderes |
| `GitHub Webhook Trigger` – Ausschnitt `body.ref`, `body.head_commit.id` | |
| `Filter Push Event` – Anzahl Items (0 = übersprungen wegen Auto-Backup) | |
| `Extrahiere geänderte Dateien` – `filePath`-Liste | |
| Erster fehlerhafter Node (Name) | |
| Fehlermeldung / HTTP-Status | |

**Nodes in Reihenfolge:** `GitHub Webhook Trigger` → `Filter Push Event` → `Extrahiere geänderte Dateien` → `Hole Datei von GitHub` → `Parse Workflow` → … → `Debug: Ergebnis`.

---

## 3. Symptom → Ursache → Maßnahme

| Symptom | Wahrscheinliche Kategorie | Prüfen / Maßnahme |
|---------|---------------------------|-------------------|
| Execution endet sofort, keine nachfolgenden Nodes | `Filter Push Event` liefert **keine** Items | Erwartet bei reinem **Auto-Backup-Push** (`Auto-Backup` in Commit-Message). User-Pushes auf `main` ohne dieses Muster sollten Items erzeugen. |
| `Extrahiere geänderte Dateien` liefert keine Items bei User-Push | Leere `commits`-Liste im Webhook | Repo-Workflow nutzt Fallback über `head_commit`; Payload in Execution prüfen. |
| Falsche Workflow-Zuordnung bei **mehreren** JSON-Dateien | Früher: `$node`-Referenz | Aktuell: `$('Parse Workflow').item` — bei Alt-Import in n8n JSON aus Repo erneut einspielen. |
| HTTP 401/403 | n8n-API-Key / GitHub-Credential | Credentials in n8n prüfen. |
| HTTP 404 bei GET Workflow | Workflow-ID existiert in n8n nicht | Erwartet bei neuem Workflow → Pfad **Erstelle Workflow**. |
| HTTP 422 bei PUT | Request-Body vs. n8n-API | Body in `Update Workflow` / API-Doku abgleichen. |
| Merge auf `main` kurz danach wieder „alter“ Stand auf GitHub | Race: Backup vor Sync | [BEST_PRACTICES.md](../../../BEST_PRACTICES.md) §2 und §5: Backup kurz deaktivieren, mergen, Sync grün, dann Backup an. |

---

## 4. Deploy- und Betriebs-Checkliste (Race vermeiden)

1. Bei Merge von Änderungen unter `n8n/…` nach **`main`:** Backup-Workflow **n8n GitHub Backup** in n8n **deaktivieren**.
2. Merge durchführen (oder `git push` nach `main`).
3. **GitHub → n8n Synchronisation** ausführen lassen (Webhook) oder manuell testen; Execution **grün**.
4. In n8n-Editor Sticky Note / erwartete Änderung prüfen.
5. Backup-Workflow wieder **aktivieren**.

Weitere Regeln: [BEST_PRACTICES.md](../../../BEST_PRACTICES.md).
