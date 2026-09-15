#!/usr/bin/env bash
# hypd: holt, was gerade hyped ist.
#   Hacker News Top-Stories · neue MCP-Server (30 Tage) · GitHub-Repos der Woche
# Schreibt $HYPD_CACHE (Default ~/.claude/hypd.json). Läuft auf Linux und macOS.
# Abhängigkeiten: curl, jq. Optional: gh (eingeloggt) für höhere GitHub-Limits.
set -u
OUT=${HYPD_CACHE:-$HOME/.claude/hypd.json}
LOCKDIR="$OUT.lock"
mkdir -p "$(dirname "$OUT")"
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  # Lock älter als 2 min → verwaist, übernehmen
  if [ -n "$(find "$LOCKDIR" -maxdepth 0 -mmin +2 2>/dev/null)" ]; then rm -rf "$LOCKDIR"; mkdir "$LOCKDIR" || exit 0; else exit 0; fi
fi
trap 'rm -rf "$LOCKDIR"' EXIT

days_ago() { date -d "$1 days ago" +%Y-%m-%d 2>/dev/null || date -v-"$1"d +%Y-%m-%d; }

# Hacker News
hn="[]"
hn_ids=$(curl -s -m 8 https://hacker-news.firebaseio.com/v0/topstories.json | jq -c '.[0:15]' 2>/dev/null)
if [ -n "$hn_ids" ]; then
  hn=$(for id in $(echo "$hn_ids" | jq -r '.[]'); do
    curl -s -m 5 "https://hacker-news.firebaseio.com/v0/item/$id.json"
  done | jq -s '[.[] | select(.title) | {title, url: (.url // ("https://news.ycombinator.com/item?id=" + (.id|tostring))), score, comments: (.descendants // 0), hn: ("https://news.ycombinator.com/item?id=" + (.id|tostring))}]' 2>/dev/null || echo "[]")
fi

# GitHub: gh wenn eingeloggt, sonst anonym per curl
JQ_REPOS='[.items[] | {name: .full_name, stars: .stargazers_count, desc: (.description // ""), url: .html_url, lang: (.language // "")}]'
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  gh_q() { gh api -X GET search/repositories -f q="$1" -f sort=stars -f order=desc -f per_page=8 --jq "$JQ_REPOS" 2>/dev/null || echo "[]"; }
else
  gh_q() { curl -s -m 10 -G -H 'Accept: application/vnd.github+json' https://api.github.com/search/repositories --data-urlencode "q=$1" --data-urlencode sort=stars --data-urlencode order=desc --data-urlencode per_page=8 | jq "$JQ_REPOS" 2>/dev/null || echo "[]"; }
fi
mcp=$(gh_q "topic:mcp created:>$(days_ago 30)")
[ "$(echo "$mcp" | jq length 2>/dev/null || echo 0)" -lt 3 ] && mcp=$(gh_q "mcp server in:name,description created:>$(days_ago 30)")
trending=$(gh_q "created:>$(days_ago 7) stars:>100")

jq -n --argjson hn "$hn" --argjson mcp "${mcp:-[]}" --argjson trending "${trending:-[]}" \
  --arg ts "$(date +%s)" --arg at "$(date '+%Y-%m-%d %H:%M')" \
  '{fetched: ($ts|tonumber), fetched_at: $at, hn: $hn, mcp: $mcp, trending: $trending}' > "$OUT.tmp" && mv "$OUT.tmp" "$OUT"
