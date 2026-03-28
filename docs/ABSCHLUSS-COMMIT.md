# Abschluss-Commit

Nach Abschluss einer Aufgabe in Cursor diesen Befehl ausführen:

```
git commit --allow-empty -m "[BER-XX] done: Kurzbeschreibung" && git push
```

**XX** durch die Linear-Issue-Nummer ersetzen.

## Was dann automatisch passiert

1. Linear-Issue wird auf **Done** gesetzt
2. Notion-Kommentar auf dem PARA-Hub
3. Threema-Nachricht mit Statusbericht
4. Claude aktualisiert das Dashboard beim nächsten Chat

## Beispiel

```
git commit --allow-empty -m "[BER-23] done: Textschmiede Detailseite erstellt" && git push
```

## Hinweise

- Format muss exakt sein: `[BER-XX] done:` (Groß/Kleinschreibung egal)
- `--allow-empty` nur wenn alle Änderungen schon gepusht sind
- Ohne `[BER-XX] done:` im Commit passiert nichts — normale Commits werden ignoriert
