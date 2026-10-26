#!/usr/bin/env bash
# Stop hook: collect the commands Claude asked me to run (fenced blocks whose
# info string ends in "run", e.g. ```fish run) into one JSONL file per session
# for the `claude_cmds` fish picker. The file is rebuilt from the whole
# transcript each time, so repeated Stop events don't duplicate entries.
input=$(cat)
session=$(jq -r '.session_id // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
[ -n "$session" ] && [ -f "$transcript" ] || exit 0

dir="$HOME/.cache/claude/suggested-commands"
mkdir -p "$dir"
find "$dir" -name '*.jsonl' -mtime +7 -delete

out="$dir/$session.jsonl"
# Stop can fire before the final message is flushed to the transcript, so
# read it a moment later in the background.
(
  sleep 2
  jq -c 'select(.type == "assistant") | .timestamp as $ts | .cwd as $cwd
    | .message.content[]? | select(.type == "text") | .text
    | capture("(?:^|\n)(?<indent>[ \t]*)```[^\n]*\\brun[ \t]*\n(?<body>[\\s\\S]*?)\n[ \t]*```"; "g")
    | .indent as $indent
    | {ts: $ts, cwd: $cwd, cmd: (.body | split("\n") | map(ltrimstr($indent)) | join("\n"))}' "$transcript" >"$out.tmp"

  if [ -s "$out.tmp" ]; then
    mv "$out.tmp" "$out"
  else
    rm -f "$out.tmp"
  fi
) </dev/null >/dev/null 2>&1 &
exit 0
