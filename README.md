<p align="center"><img src="assets/icon.png" width="160" alt="hypd dragon"></p>

# 🐉 hypd

**What's hyped right now, inside Claude Code.**

`/hypd` shows Hacker News top stories, the hottest new MCP servers of the last 30 days and this week's fastest-growing GitHub repos. One command, 30 lines, plus one line on what matters for *your* projects.

```
⚡ hypd · Stand 2026-09-15 20:11

Hacker News (Top 8)
 1. Show HN: An e-ink frame that hears birds and draws them as 1800s illustrations ▲797 · 114 Kommentare
    https://github.com/arnegiacomo/fugleramme
 …
MCP-Server, neu in 30 Tagen (Top 5)
 · CopilotKit/OpenBot ★4938 · Open-source AI coworkers that each get a computer of their own
 …
GitHub, neu diese Woche (Top 5)
 · Chuloo/mural ★987 · Kotlin · The language app you eventually delete
 …
```

## Install

```
/plugin marketplace add Seakuh/hypd
/plugin install hypd@hypd
```

Then run `/hypd:hypd` (plugin skills are namespaced; `/hypd` works too when nothing else claims the name).

Needs `curl` and `jq`. `gh` (logged in) is optional and lifts the GitHub rate limit.

## Commands

| Command | What you get |
|---|---|
| `/hypd` | everything, compact |
| `/hypd hn` | Hacker News, all 15 |
| `/hypd mcp` | new MCP servers, all 8, with descriptions |
| `/hypd repos` | GitHub repos of the week, all 8 |
| `/hypd refresh` | force a fresh fetch |
| `/hypd 3` | open story 3 and summarize it in 5 lines |

Answers in the user's language (German by default, since that's where the dragon lives).

## Optional: ticker in your status line

`statusline-snippet.sh` adds a neon-green line to your Claude Code status line that rotates through the top stories every 8 seconds. Each headline is a terminal hyperlink: **Ctrl+click** opens it in the browser (GNOME Terminal, Ptyxis, kitty, WezTerm, iTerm2).

```
⚡ Show HN: Capsule – Single-file web apps that save their data into SQLite ▲188 /hypd
```

The cache (`~/.claude/hypd.json`) refreshes in the background every 30 minutes and never blocks the status line.

## How it works

- `skills/hypd/hypd-fetch.sh` pulls the [Hacker News API](https://github.com/HackerNews/API) and the GitHub search API (`topic:mcp created:>30d`, `created:>7d stars:>100`), writes one JSON file.
- The skill reads that file and formats it. No LLM calls for the fetch itself.
- Linux and macOS.

## License

MIT · made by [Vartakt](https://github.com/Seakuh)
