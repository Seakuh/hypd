# ── hypd: Ticker-Zeile für deine Claude-Code-Statuszeile (optional) ──────────
# In dein Statuszeilen-Skript einfügen, dort wo du die Zeile ausgeben willst.
# Voraussetzungen: jq. Der Cache wird alle 30 min im Hintergrund aktualisiert.
# Schlagzeile ist ein OSC-8-Hyperlink: Ctrl+Klick öffnet sie im Browser (VTE, kitty, WezTerm, iTerm2).
HYPD=~/.claude/hypd.json
HYPD_FETCH=$(find ~/.claude/plugins -name hypd-fetch.sh 2>/dev/null | head -1)   # installiertes Plugin
C_HYPE=$'\e[38;5;118m'; C_DIM=$'\e[2m'; R=$'\e[0m'
tick=$(( $(date +%s) / 8 ))   # alle 8 s nächste Schlagzeile
hypd_line=""
fetched=0
if [ -f "$HYPD" ]; then
  fetched=$(jq -r '.fetched // 0' "$HYPD" 2>/dev/null)
  n=$(jq -r '.hn|length' "$HYPD" 2>/dev/null)
  if [ "${n:-0}" -gt 0 ]; then
    i=$(( tick % n ))
    head=$(jq -r --argjson i "$i" '.hn[$i] | "\(.title) ▲\(.score)"' "$HYPD")
    url=$(jq -r --argjson i "$i" '.hn[$i].url // empty' "$HYPD")
    [ ${#head} -gt 90 ] && head="${head:0:88}…"
    [ -n "$url" ] && head=$'\e]8;;'"$url"$'\e\\'"$head"$'\e]8;;\e\\'
    hypd_line="${C_HYPE}⚡ ${head}${R} ${C_DIM}/hypd${R}"
  fi
fi
if [ $(( $(date +%s) - ${fetched:-0} )) -gt 1800 ] && [ -x "$HYPD_FETCH" ]; then
  (nohup "$HYPD_FETCH" >/dev/null 2>&1 &)
fi
# dann z. B.:  printf '%s\n%s' "$deine_zeile" "$hypd_line"
