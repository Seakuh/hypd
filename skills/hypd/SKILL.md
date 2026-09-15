---
name: hypd
description: Zeigt, was gerade hyped ist – Hacker-News-Top-Stories, neue MCP-Server der letzten 30 Tage und GitHub-Repos der Woche nach Stars. "/hypd" = alles kompakt, "/hypd hn" = nur Hacker News, "/hypd mcp" = nur MCP-Server, "/hypd repos" = nur GitHub-Trending, "/hypd refresh" = neu laden, "/hypd <nr>" = Story Nr. n zusammenfassen. Auch bei "was ist gerade hyped", "news", "what's trending", "welcher mcp ist gerade angesagt".
---

# /hypd 🐉

Argument: `$ARGUMENTS`. Antworte in der Sprache des Nutzers (Default Deutsch, du-Form), kurz, keine Einleitung. Titel bleiben im Original.

Daten: `~/.claude/hypd.json` (Felder `fetched_at`, `hn[]`, `mcp[]`, `trending[]`).
Wenn die Datei fehlt, `fetched` älter als 30 min ist oder `refresh` verlangt wird:
`bash "<Base directory dieses Skills>/hypd-fetch.sh"` ausführen (das Skript liegt neben dieser SKILL.md; dauert ~6 s), dann lesen.
Schnell auslesen: `jq -r '...' ~/.claude/hypd.json`.

## Argumente
- leer → Modus ALLES
- `hn` → nur Hacker News, alle 15
- `mcp` → nur MCP-Server, alle 8, mit Beschreibung
- `repos` / `github` / `trending` → nur GitHub-Repos der Woche, alle 8
- `refresh` / `neu` → Fetch erzwingen, dann Modus ALLES
- Zahl n → Story n aus `hn[]` per WebFetch öffnen und in 5 Zeilen zusammenfassen (Was, warum relevant, Bezug zu den Projekten des Nutzers, falls aus dem Kontext bekannt)

## Modus ALLES (max. 30 Zeilen)
```
⚡ hypd · Stand <fetched_at>

Hacker News (Top 8)
 1. <title> ▲<score> · <comments> Kommentare
    <url>
 …
MCP-Server, neu in 30 Tagen (Top 5)
 · <name> ★<stars> · <desc in max 60 Zeichen>
 …
GitHub, neu diese Woche (Top 5)
 · <name> ★<stars> · <lang> · <desc in max 60 Zeichen>
 …
```
Danach genau eine Zeile: das eine Ding, das für den Nutzer am relevantesten ist (aus dem, was du über seine Projekte weißt), mit einem Halbsatz warum. Nichts erfinden, nur aus den Daten.
