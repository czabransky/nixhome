#!/usr/bin/env bash
# PreToolUse hook: deny recursive rm unless it runs alone with literal paths, so the
# permission prompt (and any path-based rule) sees exactly what gets deleted.
cmd=$(jq -r '.tool_input.command // empty')
grep -Eq '(^|[;&|(`[:space:]])rm[[:space:]]+(-[a-zA-Z]*[rR]|--recursive)' <<<"$cmd" || exit 0
if grep -Eq '[$`*?]|&&|\|\||;|\|' <<<"$cmd" || [ "$(wc -l <<<"$cmd")" -gt 1 ]; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: "Run rm -r as a command of its own: no pipes, &&, || or ;, and every path written out in full (no variables, globs or $(...))."}}'
fi
