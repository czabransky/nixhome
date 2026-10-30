function claude_cmds --description "Pick commands Claude asked me to run and insert them on the command line (ctrl-y copies instead)"
	# --pane: run from a herdr popup; enter types the command into the focused
	# pane (as a ! command when Claude runs there) instead of this command line.
	argparse pane -- $argv; or return

	set -f files (command ls -t $HOME/.cache/claude/suggested-commands/*.jsonl 2>/dev/null)
	if test (count $files) -eq 0
		echo "claude_cmds: no suggested commands yet" >&2
		if set -q _flag_pane
			read -n 1 -P 'Press any key to close'
		else
			commandline -f repaint
		end
		return 1
	end

	# Typing 1-9 on an empty query picks the Nth newest command.
	set -f digit_binds
	for n in (seq 9)
		set -a digit_binds --bind "$n:transform:test -z {q}; and echo 'pos($n)+accept'; or echo 'put($n)'"
	end

	# Items are fed newest first and drawn bottom-up, so the list reads oldest to
	# newest and item N is the Nth newest. Fields: N, cwd, display line, command.
	# The number's color alternates per response.
	# fzf prints the pressed --expect key (empty for enter), then the selections.
	set -f result (
		cat $files | jq -sj '
			to_entries | sort_by([.value.ts, .key]) | reverse | map(.value)
			| reduce .[] as $c ([]; if any(.[]; .ts == $c.ts and .cmd == $c.cmd) then . else . + [$c] end)
			| . as $l | range(length) as $i | $l[$i] as $c
			| (([$l[:$i + 1][].ts] | unique | length) % 2 | if . == 1 then "36" else "35" end) as $color
			| ($c.ts | sub("[.][0-9]+Z$"; "Z") | fromdateiso8601 | strflocaltime("%a %H:%M")) as $time
			| ($i + 1 | tostring | if length < 2 then " " + . else . end) as $n
			| "\($i + 1)\u001f\($c.cwd)\u001f\u001b[\($color)m\($n)\u001b[0m \u001b[2m\($time)\u001b[0m  \($c.cmd)\u001f\($c.cmd)\u0000"' | \
		_fzf_wrapper \
			--read0 --print0 \
			--ansi \
			--multi \
			--layout=default \
			--expect=ctrl-y \
			--delimiter=\x1f \
			--with-nth=3 \
			--prompt='Claude> ' \
			--header='enter: insert, 1-9: Nth newest, tab: select several, ctrl-y: copy' \
			--preview='echo {2}' \
			--preview-window=up,1 \
			$digit_binds | \
		string split0
	)

	if test (count $result) -lt 2
		set -q _flag_pane; or commandline -f repaint
		return 0
	end

	# Oldest first: the highest N comes first.
	set -f cmds
	for item in (printf '%s\0' $result[2..] | sort -z -t \x1f -k1,1nr | string split0)
		set -a cmds (string split --fields 4 \x1f -- $item | string collect)
	end
	set -f cmd (string join ' && ' -- $cmds | string collect)
	# Copied commands may be pasted into bash or zsh, which lack fish's `; and` / `; or`.
	set -f copied (string replace -a '; and ' ' && ' -- $cmd | string replace -a '; or ' ' || ' | string collect)

	if not set -q _flag_pane
		if test "$result[1]" = ctrl-y
			printf '%s' $copied | fish_clipboard_copy
		else
			commandline -r -- $cmd
		end
		commandline -f repaint
		return 0
	end

	# A newline sent to a pane acts as Enter, so multi-line commands are copied instead.
	if test "$result[1]" = ctrl-y; or test (count (string split \n -- $cmd)) -gt 1
		printf '%s' $copied | fish_clipboard_copy
		return 0
	end

	set -f pane (herdr pane list | jq -r '.result.panes[] | select(.focused) | "\(.pane_id)\t\(.agent // "")"' | string split \t)
	if test "$pane[2]" = claude
		herdr pane send-text $pane[1] '!'
	end
	herdr pane send-text $pane[1] $cmd
end
