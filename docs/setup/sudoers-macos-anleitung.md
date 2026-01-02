# Sudo-Rechte gezielt für einzelne Benutzer auf macOS vergeben (ohne Admin-Gruppe)

## Ziel
Einzelne Benutzer (z. B. `hpcn`, `kunkel`) sollen Sudo-Rechte erhalten, **ohne** Mitglied der Admin-Gruppe zu sein.

---

## 1. Voraussetzungen
- Mindestens ein Benutzer mit Root- oder Admin-Rechten (z. B. `adminku`).
- Zugriff auf das Terminal.

---

## 2. Sudoers-Datei gezielt anpassen

1. **Als Admin-Benutzer (z. B. `adminku`) anmelden.**
2. Terminal öffnen und mit visudo bearbeiten:
   ```sh
   sudo visudo
   ```
3. **Folgende Zeilen am Ende ergänzen:**
   ```sh
   hpcn   ALL=(ALL)   NOPASSWD: ALL
   kunkel ALL=(ALL)   NOPASSWD: ALL
   ```
   (Ohne `NOPASSWD:` wird das Passwort abgefragt.)
4. Speichern und schließen.

---

## 3. Alternative: /etc/sudoers.d/ nutzen

Für jeden Benutzer eine eigene Datei anlegen:
```sh
sudo visudo -f /etc/sudoers.d/hpcn
```
Inhalt:
```sh
hpcn ALL=(ALL) NOPASSWD: ALL
```

---

## 4. Rechte und Syntax prüfen
- `/etc/sudoers` muss die Rechte `-r--r----- root wheel` haben.
- Immer mit `visudo` bearbeiten (Syntaxprüfung!).

---

## 5. Testen
- Mit dem jeweiligen Benutzer ab- und wieder anmelden.
- Im Terminal testen:
  ```sh
  sudo whoami
  ```
  Ausgabe sollte `root` sein.
- Mit `sudo -l` anzeigen lassen, welche Rechte der Benutzer hat.

---

## 6. Troubleshooting
- Bei Problemen: Prüfe `/etc/sudoers` und `/etc/sudoers.d/` auf Syntaxfehler und Rechte.
- Prüfe, ob restriktive Einträge in `/etc/pam.d/sudo` existieren (z. B. Zeile mit `pam_group.so`).
- System-Log beim Testen beobachten:
  ```sh
  tail -f /var/log/system.log
  ```

---

## 7. Hinweise
- Standard-macOS prüft normalerweise die Admin-Gruppenmitgliedschaft. Mit gezielten sudoers-Einträgen kann das umgangen werden, **sofern keine restriktive PAM-Konfiguration aktiv ist**.
- Änderungen an `/etc/pam.d/sudo` sind möglich, aber sicherheitskritisch und sollten nur mit Bedacht erfolgen.

---

**Fragen oder Probleme?**
Gerne diese Anleitung erweitern oder anpassen! 