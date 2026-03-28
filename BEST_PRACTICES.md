# n8n ↔ GitHub: Best Practices für Synchronisation & Backup
<!-- Letzte Pruefung: 2026-03-28 -->

Dieses Dokument beschreibt das Architektur-Konzept und die Best Practices für das Zusammenspiel zwischen n8n und GitHub, um Konflikte (Race Conditions) zu vermeiden.

## Das Kernproblem: Die Race Condition (Wettrennen)

In einem bidirektionalen System, bei dem **Workflow A** (Backup) Daten nach GitHub schreibt und **Workflow B** (Sync) Daten von GitHub nach n8n lädt, kann ein Konflikt entstehen:
- Du reparierst eine Datei auf GitHub.
- Bevor der Sync-Workflow die Änderung in n8n einspielen kann, startet das automatisierte Backup in n8n.
- Da n8n noch die "alte" Logik im Speicher hat, schreibt das Backup den alten Stand zurück nach GitHub und überschreibt deine Reparatur.

## 1. Installations-Strategie (New Setup)

Um von Anfang an einen sauberen Stand zu haben, sollte die Installation nach dem "Sync-First"-Prinzip erfolgen:

1.  **Repository vorbereiten**: Lade alle `.json` Dateien deiner Workflows direkt in das GitHub-Repository hoch.
2.  **Sync-Workflow importieren**: Importiere nur den `GitHub → n8n Synchronisation` Workflow manuell in n8n.
3.  **Initialer Sync**: Starte den Sync-Workflow manuell. Er lädt nun alle anderen Workflows (inkl. des Backup-Workflows) direkt von GitHub in die n8n Datenbank.
4.  **Ergebnis**: n8n und GitHub sind zu 100% synchron, bevor die Automatismen starten.

## 2. Wartungs-Strategie (Updates an der Logik)

Wenn Änderungen am Backup-Workflow oder anderen kritischen Files vorgenommen werden:

- **Empfohlen**: Deaktiviere den Backup-Workflow kurzzeitig in n8n, pushe die Änderung nach GitHub und warte auf den automatischen Sync-Lauf. Aktiviere ihn erst wieder, wenn die neue Version im n8n-Editor sichtbar ist.
- **Notfall-Lösung (Manueller Import)**: Falls sich das System in einer Race-Condition verfangen hat, ist ein manueller Import der JSON-Datei in den n8n-Editor der sicherste Weg, um die n8n-Datenbank "hart" auf den neuesten Stand zu bringen.

## 3. Goldene Regeln

> [!IMPORTANT]
> **GitHub ist der Master für die Logik (Code/Versionen).**
> **n8n ist der Master für die Aktivität (Laufzeit/Trigger).**

1.  Standard-Änderungen (Workflow-Logik, Node-Parameter) sollten idealerweise über GitHub eingespielt werden.
2.  Änderungen direkt in der n8n-UI werden beim nächsten 15-Minuten-Lauf automatisch nach GitHub gesichert.
3.  Nutze **Versions-Markierungen** (z.B. Sticky Notes mit `v4.2`) im Workflow, um auf einen Blick zu sehen, welcher Stand gerade in n8n aktiv ist.

## 4. Webhook Trigger vs. Cron
- Der Sync-Workflow sollte bevorzugt per **GitHub Webhook** getriggert werden. Dies minimiert das Zeitfenster für Konflikte, da n8n fast unmittelbar nach einem Push aktualisiert wird.

## 5. Ökosystem: Checkliste für KI-Tools, Feature-Branches und Merge

Damit GitHub, n8n und automatische Jobs nicht gegeneinander arbeiten:

1. **Workflow-Logik gehört nach `main` (oder du akzeptierst, dass n8n nicht nachzieht):** Der Sync-Workflow liest Dateien von **`main`**. Änderungen nur auf einem Feature-Branch sind in n8n unsichtbar, bis sie gemerged sind.
2. **Vor Merge von `n8n/…`-JSON:** Backup-Workflow in n8n **kurz deaktivieren**, PR nach `main` mergen, warten bis **GitHub → n8n Synchronisation** erfolgreich gelaufen ist (Webhook-Execution prüfen), im Editor verifizieren, dann Backup **wieder aktivieren**.
3. **Nach Merge:** Kurz prüfen, ob der Sync-Lauf **grün** ist. Wenn der Backup-Lauf vor dem Sync noch einmal nach `main` schreibt, kann der alte n8n-Stand die frische Merge-Version überschreiben (siehe Abschnitt „Race Condition“).
4. **Konvention für Auto-Commits:** Backup-Commits enthalten `Auto-Backup` in der Message; der Sync ignoriert solche Pushes bewusst, damit keine Schleifen entstehen.
5. **Sticky Note / Versions-Tags** in kritischen Workflows beibehalten, damit du im Editor siehst, ob n8n wirklich den Stand von GitHub hat.

## 6. Technische Anmerkungen zum Sync (Repo-Stand)

- Bei **großen Pushes** kann GitHub eine **leere `commits`-Liste** liefern; der Workflow fällt auf **`head_commit`** zurück.
- Bei **mehreren geänderten JSON-Dateien** pro Push müssen Parse-Daten **pro Item** (`$('Parse Workflow').item`) angebunden sein, nicht nur der letzte `$node`-Stand.
- Detaillierte Analyse, Evidenz-Vorlage und Symptom-Matrix: [n8n/docs/debugging/SYNC-ANALYSE-UND-EVIDENZ.md](n8n/docs/debugging/SYNC-ANALYSE-UND-EVIDENZ.md).
