# Setup-Anleitung: Multi-Computer Multi-User Cursor Workspace

## Übersicht

Diese Anleitung beschreibt das komplette Setup für mehrere Rechner mit mehreren Benutzern, die gemeinsam an n8n-Workflows arbeiten.

## Architektur

```
Rechner 1:
  /Users/Shared/n8n-workflows/  ← Haupt-Workspace (Git Repository)
  Owner: kunkel:staff
  Symlinks:
    /Users/kunkel/n8n-workflows → /Users/Shared/n8n-workflows

Rechner 2:
  /Users/Shared/n8n-workflows/  ← Git Clone
  Owner: kunkel:staff
  Symlinks:
    /Users/kunkel/n8n-workflows → /Users/Shared/n8n-workflows
    /Users/hpcn/n8n-workflows → /Users/Shared/n8n-workflows

Zwischen Rechnern: Git Push/Pull
Chat-Historie: Cloud-Sync (iCloud/Dropbox) - optional
```

**Wichtig:** Der Owner ist immer `kunkel:staff` (auch auf Rechner 2, damit beide Benutzer Zugriff haben).

---

## Schritt 1: Workspace nach /Users/Shared/ verschieben

**Nur auf dem ersten Rechner nötig!**

### Voraussetzungen
- Als Admin-Benutzer eingeloggt (z.B. `adminku`)
- Workspace noch nicht verschoben

### Ausführung

```bash
cd /Users/kunkel/n8n-workflows  # Oder wo auch immer der Workspace liegt
./docs/setup/move-to-shared.sh
```

Das Script:
1. ✅ Verschiebt Workspace nach `/Users/Shared/n8n-workflows`
2. ✅ Erstellt Symlink `/Users/kunkel/n8n-workflows` → `/Users/Shared/n8n-workflows`
3. ✅ Setzt Berechtigungen (`775` für Verzeichnisse, `664` für Dateien)
4. ✅ Setzt Owner auf `kunkel:staff`
5. ✅ Unterstützt Resume bei Abbruch

### Prüfung

```bash
# Prüfe Symlink
ls -la /Users/kunkel/n8n-workflows

# Prüfe Berechtigungen
stat -f "%Sp %N" /Users/Shared/n8n-workflows
stat -f "%Sp %N" /Users/Shared/n8n-workflows/README.md

# Prüfe Owner
ls -ld /Users/Shared/n8n-workflows
# Sollte zeigen: kunkel staff

# Prüfe Schreibzugriff
cd /Users/kunkel/n8n-workflows
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
git clone https://github.com/peerendees/n8n-workflows.git n8n-workflows
cd n8n-workflows
```

**✅ Prüfung:**
```bash
ls -la
# Sollte alle Dateien zeigen (README.md, docs/, n8n/, etc.)
```

### 3.2 Berechtigungen setzen

**Wichtig:** Das Script muss als Admin-Benutzer ausgeführt werden!

```bash
# Als Admin-Benutzer
cd /Users/Shared/n8n-workflows
./docs/setup/fix-permissions.sh
```

**Falls das Script nicht ausführbar ist:**
```bash
chmod +x docs/setup/fix-permissions.sh
./docs/setup/fix-permissions.sh
```

**Was das Script macht:**
- ✅ Setzt Owner/Gruppe auf `kunkel:staff` (falls vorhanden, sonst automatische Erkennung)
- ✅ Setzt Verzeichnis-Berechtigungen auf `775`
- ✅ Setzt Datei-Berechtigungen auf `664`
- ✅ Macht Scripts ausführbar (`775`)

**✅ Prüfung:**
```bash
stat -f "%Sp %N" /Users/Shared/n8n-workflows
stat -f "%Sp %N" /Users/Shared/n8n-workflows/README.md
# Sollte zeigen: drwxrwxr-x für Verzeichnisse, -rw-rw-r-- für Dateien
```

**Oder manuell (falls Script nicht funktioniert):**
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

**✅ Prüfung:**
```bash
cd ~/n8n-workflows
ls -la
# Sollte alle Dateien zeigen
```

**Wichtig:** Alle Benutzer müssen in der `staff`-Gruppe sein:
```bash
# Als Admin prüfen:
groups [benutzername]

# Falls nicht: Hinzufügen
sudo dseditgroup -o edit -a [benutzername] -t user staff
```

### 3.4 Git Pull (neueste Änderungen holen)

**Wichtig:** Bevor du arbeitest, hole die neuesten Änderungen!

```bash
cd /Users/Shared/n8n-workflows
git pull origin main
```

**✅ Prüfung:**
```bash
git status
# Sollte "nothing to commit, working tree clean" zeigen
```

### 3.5 Cursor Workspace öffnen

**Wichtig:** Immer den Symlink verwenden, nicht den direkten Pfad!

1. **Cursor öffnen**
2. **File → Open Folder**
3. **Symlink auswählen:** `/Users/[benutzername]/n8n-workflows`
   - **NICHT:** `/Users/Shared/n8n-workflows` ❌

**✅ Prüfung:**
```bash
cd ~/n8n-workflows
./docs/setup/check-cursor-workspace.sh
```

### 3.6 Schreibzugriff testen

```bash
cd ~/n8n-workflows
touch test-datei.txt
echo "Test" > test-datei.txt
rm test-datei.txt
```

**✅ Wenn das funktioniert:** Alles ist korrekt eingerichtet!

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
# Richtig (als kunkel):
open /Users/kunkel/n8n-workflows

# Oder (als hpcn auf Rechner 2):
open /Users/hpcn/n8n-workflows

# Oder in Cursor:
# File → Open Folder → /Users/kunkel/n8n-workflows
# Oder: File → Open Folder → /Users/hpcn/n8n-workflows
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
2. File → Open Folder → `/Users/kunkel/n8n-workflows` oder `/Users/hpcn/n8n-workflows` (Symlink!)
3. Workspace-Storage wird automatisch erstellt

### Problem: Chats nicht sichtbar

**Ursache:** Falscher Pfad verwendet (direkter Pfad statt Symlink)

**Lösung:**
- Immer den Symlink verwenden: `/Users/kunkel/n8n-workflows` oder `/Users/hpcn/n8n-workflows`
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

- [ ] Git Repository geklont nach `/Users/Shared/n8n-workflows` (Schritt 3.1)
- [ ] Berechtigungen gesetzt (`fix-permissions.sh` ausgeführt) (Schritt 3.2)
- [ ] Symlinks für alle Benutzer erstellt (Schritt 3.3)
- [ ] Git Pull durchgeführt (`git pull origin main`) um neueste Änderungen zu holen (Schritt 3.4)
- [ ] Cursor Workspace-Storage geprüft (`check-cursor-workspace.sh`) (Schritt 3.5)
- [ ] Workspace in Cursor geöffnet (über Symlink!) (Schritt 3.5)
- [ ] Schreibzugriff getestet (Test-Datei erstellen) (Schritt 3.6)
- [ ] Git funktioniert (`git status`)

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

