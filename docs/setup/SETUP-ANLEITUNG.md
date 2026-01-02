# Setup-Anleitung: Multi-Computer Multi-User Cursor Workspace

## Übersicht

Diese Anleitung beschreibt das komplette Setup für mehrere Rechner mit mehreren Benutzern, die gemeinsam an n8n-Workflows arbeiten.

## Architektur

```
Rechner 1:
  /Users/Shared/n8n-workflows/  ← Haupt-Workspace (Git Repository)
  Symlinks:
    /Users/hpcn/n8n-workflows → /Users/Shared/n8n-workflows
    /Users/kunkel/n8n-workflows → /Users/Shared/n8n-workflows

Rechner 2:
  /Users/Shared/n8n-workflows/  ← Git Clone
  Symlinks:
    /Users/benutzer1/n8n-workflows → /Users/Shared/n8n-workflows
    /Users/benutzer2/n8n-workflows → /Users/Shared/n8n-workflows

Zwischen Rechnern: Git Push/Pull
Chat-Historie: Cloud-Sync (iCloud/Dropbox) - optional
```

---

## Schritt 1: Workspace nach /Users/Shared/ verschieben

**Nur auf dem ersten Rechner nötig!**

### Voraussetzungen
- Als Admin-Benutzer eingeloggt (z.B. `adminku`)
- Workspace noch nicht verschoben

### Ausführung

```bash
cd /Users/hpcn/n8n-workflows  # Oder wo auch immer der Workspace liegt
./docs/setup/move-to-shared.sh
```

Das Script:
1. ✅ Verschiebt Workspace nach `/Users/Shared/n8n-workflows`
2. ✅ Erstellt Symlink `/Users/hpcn/n8n-workflows` → `/Users/Shared/n8n-workflows`
3. ✅ Setzt Berechtigungen (`775` für Verzeichnisse, `664` für Dateien)
4. ✅ Unterstützt Resume bei Abbruch

### Prüfung

```bash
# Prüfe Symlink
ls -la /Users/hpcn/n8n-workflows

# Prüfe Berechtigungen
stat -f "%Sp %N" /Users/Shared/n8n-workflows
stat -f "%Sp %N" /Users/Shared/n8n-workflows/README.md

# Prüfe Schreibzugriff
cd /Users/hpcn/n8n-workflows
touch test.txt && rm test.txt
```

---

## Schritt 2: Weitere Benutzer auf demselben Rechner

### Für jeden weiteren Benutzer:

```bash
# Als Benutzer einloggen
ln -s /Users/Shared/n8n-workflows ~/n8n-workflows

# Prüfen
cd ~/n8n-workflows
ls -la
```

**Wichtig:** Alle Benutzer müssen in der `staff`-Gruppe sein:
```bash
# Als Admin prüfen:
groups [benutzername]

# Falls nicht: Hinzufügen
sudo dseditgroup -o edit -a [benutzername] -t user staff
```

---

## Schritt 3: Weitere Rechner einrichten

### 3.1 Git Repository klonen

```bash
# Als Admin-Benutzer auf neuem Rechner
cd /Users/Shared
git clone [dein-github-repo-url] n8n-workflows
cd n8n-workflows
```

### 3.2 Berechtigungen setzen

```bash
# Als Admin-Benutzer
./docs/setup/fix-permissions.sh
```

Oder manuell:
```bash
sudo chown -R [erster-benutzer]:staff /Users/Shared/n8n-workflows
sudo find /Users/Shared/n8n-workflows -type d -exec chmod 775 {} \;
sudo find /Users/Shared/n8n-workflows -type f -exec chmod 664 {} \;
sudo find /Users/Shared/n8n-workflows -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod 775 {} \;
```

### 3.3 Symlinks für Benutzer erstellen

Für jeden Benutzer auf dem Rechner:
```bash
ln -s /Users/Shared/n8n-workflows ~/n8n-workflows
```

---

## Schritt 4: Git-Workflow für Multi-Computer

### Wichtige Regeln

**Git-Operationen funktionieren sowohl direkt als auch über Symlink:**

**Option 1: Direkt im Shared-Verzeichnis (empfohlen für Git-Operationen):**
```bash
cd /Users/Shared/n8n-workflows
git add .
git commit -m "Beschreibung"
git push origin main
```

**Option 2: Über Symlink (funktioniert auch, Git löst Symlink auf):**
```bash
cd ~/n8n-workflows  # Symlink zeigt auf /Users/Shared/n8n-workflows
git add .
git commit -m "Beschreibung"
git push origin main
```

**Beide Wege sind gleichwertig** - Git erkennt automatisch das Repository-Verzeichnis.

### Synchronisation zwischen Rechnern

**Auf Rechner 1 (Haupt-Rechner):**
- Änderungen machen
- Committen: `git commit -m "..."`  
- Pushen: `git push origin main` → Änderungen gehen nach GitHub

**Auf Rechner 2 (oder weiteren Rechnern):**
- **Erstes Mal:** Repository klonen (siehe Schritt 3.1)
- **Danach:** Regelmäßig Pullen um Änderungen zu holen:
  ```bash
  cd /Users/Shared/n8n-workflows
  git pull origin main
  ```

**Wichtig:** 
- Push erfolgt nur vom Rechner, der Änderungen gemacht hat
- Pull erfolgt auf allen anderen Rechnern, um Änderungen zu holen
- Keine automatische Synchronisation - manuell `git pull` nötig
- Git-Operationen funktionieren sowohl direkt (`/Users/Shared/n8n-workflows`) als auch über Symlink (`~/n8n-workflows`)

### Täglicher Workflow

**Auf Rechner 1:**
```bash
# Option A: Direkt im Shared-Verzeichnis (empfohlen)
cd /Users/Shared/n8n-workflows
# Oder Option B: Über Symlink (funktioniert auch)
# cd ~/n8n-workflows

# Arbeiten, Dateien ändern
git add .
git commit -m "Änderungsbeschreibung"
git push origin main
```

**Auf Rechner 2 (beim Wechseln):**
```bash
# Option A: Direkt im Shared-Verzeichnis (empfohlen)
cd /Users/Shared/n8n-workflows
# Oder Option B: Über Symlink
# cd ~/n8n-workflows

git pull origin main  # Holt alle Änderungen von GitHub
# Jetzt weiterarbeiten
```

**Hinweis:** Beide Wege funktionieren. Der direkte Pfad ist klarer für Git-Operationen, der Symlink ist praktischer für Cursor/Datei-Zugriff.

---

## Schritt 5: Cursor Workspace-Storage prüfen

### Prüfung

```bash
cd /Users/hpcn/n8n-workflows  # Oder über Symlink
./docs/setup/check-cursor-workspace.sh
```

Das Script zeigt:
- ✅ Workspace-Hash
- ✅ Ob Workspace-Storage existiert
- ✅ Ob Chat-Datenbank vorhanden ist
- ✅ Informationen für Multi-Computer Setup

### Workspace in Cursor öffnen

**Wichtig:** Immer den Symlink verwenden, nicht den direkten Pfad!

```bash
# Richtig:
open /Users/hpcn/n8n-workflows

# Oder in Cursor:
# File → Open Folder → /Users/hpcn/n8n-workflows
```

**Nicht verwenden:**
```bash
# Falsch (erstellt anderen Hash):
open /Users/Shared/n8n-workflows
```

---

## Schritt 5: Gemeinsame Chat-Historie (Optional)

Für gemeinsame Chat-Historie zwischen Rechnern siehe:
- `docs/setup/CURSOR-MULTI-COMPUTER-SETUP.md`
- `docs/setup/setup-cursor-cloud-sync.sh`

---

## Troubleshooting

### Problem: "Permission denied" beim Schreiben

**Lösung:**
```bash
# Als Admin-Benutzer
./docs/setup/fix-permissions.sh
```

### Problem: Workspace-Storage nicht gefunden

**Lösung:**
1. Cursor öffnen
2. File → Open Folder → `/Users/hpcn/n8n-workflows` (Symlink!)
3. Workspace-Storage wird automatisch erstellt

### Problem: Chats nicht sichtbar

**Ursache:** Falscher Pfad verwendet (direkter Pfad statt Symlink)

**Lösung:**
- Immer den Symlink verwenden: `/Users/hpcn/n8n-workflows`
- Nicht den direkten Pfad: `/Users/Shared/n8n-workflows`

### Problem: Git-Status zeigt Änderungen nach Klonen

**Lösung:**
```bash
cd /Users/Shared/n8n-workflows
git status
# Normalerweise nur lokale Änderungen, die nicht committed sind
```

---

## Wichtige Dateien

- `docs/setup/move-to-shared.sh` - Workspace verschieben (Schritt 1)
- `docs/setup/fix-permissions.sh` - Berechtigungen korrigieren
- `docs/setup/check-cursor-workspace.sh` - Workspace-Storage prüfen
- `docs/setup/CURSOR-MULTI-COMPUTER-SETUP.md` - Multi-Computer Chat-Setup
- `docs/setup/SETUP-ANLEITUNG.md` - Diese Datei

---

## Checkliste für neuen Rechner

- [ ] Git Repository geklont nach `/Users/Shared/n8n-workflows`
- [ ] Berechtigungen gesetzt (`fix-permissions.sh` ausgeführt)
- [ ] Symlinks für alle Benutzer erstellt
- [ ] Git Pull durchgeführt (`git pull origin main`) um neueste Änderungen zu holen
- [ ] Cursor Workspace-Storage geprüft (`check-cursor-workspace.sh`)
- [ ] Workspace in Cursor geöffnet (über Symlink!)
- [ ] Git funktioniert (`git status`)
- [ ] Schreibzugriff funktioniert (Test-Datei erstellen)

---

## Checkliste für neuen Benutzer

- [ ] Benutzer in `staff`-Gruppe? (`groups [benutzername]`)
- [ ] Symlink erstellt: `ln -s /Users/Shared/n8n-workflows ~/n8n-workflows`
- [ ] Workspace in Cursor geöffnet (über Symlink!)
- [ ] Schreibzugriff funktioniert

---

## Weitere Informationen

- Haupt-README: `/README.md`
- Dokumentation: `/docs/README.md`
- Workflow-Dokumentation: `/docs/workflows/`

