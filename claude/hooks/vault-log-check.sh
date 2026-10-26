#!/usr/bin/env bash
# Stop hook: once per session, if the session made at least 5 tool calls and
# never wrote to the vault's activity log, send Claude back to log the session.
# Stop fires at the end of every response, so a per-session marker keeps this to
# one nudge.
input=$(cat)
[ "$(jq -r '.stop_hook_active // false' <<<"$input")" = "true" ] && exit 0
session=$(jq -r '.session_id // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
[ -n "$session" ] && [ -f "$transcript" ] || exit 0

marker="$HOME/.local/state/claude-vault-log/$session"
[ -e "$marker" ] && exit 0

log_dir="$HOME/code/work/vault/900. Machine/Log"
tool_uses=$(jq -c 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use")' "$transcript" 2>/dev/null)
[ "$(grep -c . <<<"$tool_uses")" -lt 5 ] && exit 0
grep -q '900. Machine/Log' <<<"$tool_uses" && exit 0

mkdir -p "${marker%/*}" && touch "$marker"
echo "Before you finish: append an entry for this session to \"$log_dir/$(date +%F).md\", following \"$log_dir/AGENTS.md\". Include what was done, with links, and every follow-up you suggested that I didn't act on as a '- [ ]' line. If the session produced nothing worth recalling, say so in one line and stop." >&2
exit 2
