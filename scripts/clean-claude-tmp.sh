#!/bin/sh
# Delete folders directly under /private/tmp/claude* when nothing inside them
# has been modified in the last 7 days. Pass -n for a dry run.
set -eu

dry_run=0
[ "${1:-}" = "-n" ] && dry_run=1

for root in /private/tmp/claude*; do
  [ -d "$root" ] && [ ! -L "$root" ] || continue
  for dir in "$root"/*; do
    [ -d "$dir" ] && [ ! -L "$dir" ] || continue
    if [ -z "$(find "$dir" -mtime -7 -print -quit 2>/dev/null)" ]; then
      echo "$(date '+%F %T') removing $dir"
      [ "$dry_run" = 1 ] || rm -rf "$dir"
    fi
  done
done
