# 📋 Setup-Reihenfolge: Rechner 2 → Rechner 1

## Aktuelle Situation

- ✅ **Rechner 2 (hpcn):** Setup-Scripts und Dokumentation aktualisiert
- ⏳ **GitHub:** Änderungen noch nicht gepusht
- 🎯 **Ziel:** Rechner 1 (kunkel) einrichten

---

## Schritt 1: Änderungen auf Rechner 2 committen und pushen

**Auf Rechner 2 als hpcn:**

```bash
cd /Users/hpcn/n8n-workflows

# 1. Setup-Änderungen committen
git commit -m "🔧 Setup-Scripts: kunkel als primären Owner verwenden

- fix-permissions.sh erkennt automatisch kunkel als Owner
- SETUP-ANLEITUNG.md aktualisiert für kunkel/hpcn Setup
- Dokumentation für Multi-Computer-Setup verbessert"

# 2. Nach GitHub pushen
git push origin main
```

**✅ Prüfung:**
```bash
git status
# Sollte "nothing to commit, working tree clean" zeigen (oder nur andere uncommitted Dateien)
```

---

## Schritt 2: Auf Rechner 1 einrichten

**Auf Rechner 1 als kunkel (oder Admin-Benutzer):**

### 2.1 Git Repository klonen

```bash
# Als Admin-Benutzer
cd /Users/Shared
git clone https://github.com/peerendees/n8n-workflows.git n8n-workflows
cd n8n-workflows
```

**✅ Prüfung:**
```bash
ls -la
# Sollte alle Dateien zeigen (README.md, docs/, n8n/, etc.)
```

### 2.2 Berechtigungen setzen

```bash
# Als Admin-Benutzer
cd /Users/Shared/n8n-workflows
./docs/setup/fix-permissions.sh
```

**Was passiert:**
- Script erkennt automatisch `kunkel` als Owner
- Setzt Owner/Gruppe auf `kunkel:staff`
- Setzt Berechtigungen (`775` für Verzeichnisse, `664` für Dateien)

**✅ Prüfung:**
```bash
ls -ld /Users/Shared/n8n-workflows
# Sollte zeigen: kunkel staff
stat -f "%Sp %N" /Users/Shared/n8n-workflows
# Sollte zeigen: drwxrwxr-x
```

### 2.3 Symlink für kunkel erstellen

```bash
# Als kunkel einloggen
ln -s /Users/Shared/n8n-workflows ~/n8n-workflows
```

**✅ Prüfung:**
```bash
cd ~/n8n-workflows
ls -la
# Sollte alle Dateien zeigen
```

### 2.4 Cursor Workspace öffnen

1. **Cursor öffnen**
2. **File → Open Folder**
3. **Symlink auswählen:** `/Users/kunkel/n8n-workflows`
   - **NICHT:** `/Users/Shared/n8n-workflows` ❌

**✅ Prüfung:**
```bash
cd ~/n8n-workflows
./docs/setup/check-cursor-workspace.sh
```

### 2.5 Schreibzugriff testen

```bash
cd ~/n8n-workflows
touch test-datei.txt
echo "Test" > test-datei.txt
rm test-datei.txt
```

**✅ Wenn das funktioniert:** Alles ist korrekt eingerichtet!

---

## Schritt 3: Weitere Benutzer auf Rechner 2 (optional)

Falls auf Rechner 2 auch `hpcn` Zugriff haben soll:

**Auf Rechner 2 als hpcn:**

```bash
# Symlink erstellen (falls noch nicht vorhanden)
ln -s /Users/Shared/n8n-workflows ~/n8n-workflows

# Prüfen
cd ~/n8n-workflows
ls -la
```

**Wichtig:** `hpcn` muss in der `staff`-Gruppe sein:
```bash
# Als Admin prüfen:
groups hpcn

# Falls nicht: Als Admin hinzufügen
sudo dseditgroup -o edit -a hpcn -t user staff
```

---

## ✅ Checkliste

### Rechner 2 (hpcn):
- [ ] Setup-Änderungen committed (`git commit`)
- [ ] Nach GitHub gepusht (`git push origin main`)
- [ ] Symlink erstellt: `ln -s /Users/Shared/n8n-workflows ~/n8n-workflows`
- [ ] Workspace in Cursor geöffnet (über Symlink!)

### Rechner 1 (kunkel):
- [ ] Git Repository geklont nach `/Users/Shared/n8n-workflows`
- [ ] Berechtigungen gesetzt (`fix-permissions.sh` ausgeführt)
- [ ] Owner ist `kunkel:staff` (prüfen mit `ls -ld`)
- [ ] Symlink erstellt: `ln -s /Users/Shared/n8n-workflows ~/n8n-workflows`
- [ ] Cursor Workspace-Storage geprüft (`check-cursor-workspace.sh`)
- [ ] Workspace in Cursor geöffnet (über Symlink!)
- [ ] Schreibzugriff getestet (Test-Datei erstellen)

---

## 🔄 Täglicher Workflow

### Beim Wechseln zwischen Rechnern:

**Auf Rechner 1 (kunkel):**
```bash
cd /Users/Shared/n8n-workflows
git pull origin main  # Holt neueste Änderungen
```

**Auf Rechner 2 (hpcn oder kunkel):**
```bash
cd /Users/Shared/n8n-workflows
git pull origin main  # Holt neueste Änderungen
```

### Nach dem Arbeiten:

**Auf dem Rechner, auf dem gearbeitet wurde:**
```bash
cd /Users/Shared/n8n-workflows
git add .
git commit -m "Beschreibung der Änderungen"
git push origin main
```

---

## 🐛 Troubleshooting

### Problem: "Permission denied" auf Rechner 1

**Lösung:**
```bash
# Als Admin-Benutzer
cd /Users/Shared/n8n-workflows
./docs/setup/fix-permissions.sh
```

### Problem: Owner ist nicht kunkel

**Lösung:**
```bash
# Als Admin prüfen:
ls -ld /Users/Shared/n8n-workflows

# Falls nicht kunkel: Manuell setzen
sudo chown -R kunkel:staff /Users/Shared/n8n-workflows
```

### Problem: Git Pull zeigt Konflikte

**Lösung:**
```bash
# Status prüfen
git status

# Falls lokale Änderungen: Stash oder commit
git stash  # Oder: git commit -m "..."

# Dann pull
git pull origin main
```

