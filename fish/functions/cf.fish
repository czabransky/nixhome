function cf --description "Pick an open PR from any running cubefarm instance and queue it for QA. enter: qa, ctrl-o: open, ctrl-y: copy url, ctrl-r: rescan ports."
	# Each instance's /api/state is cached as <port>.json, so the next run only probes ports that answered last time.
	set -f cache (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo ~/.cache)/cf

	switch "$argv[1]"
		case --rows
			set -l cached $cache/*.json
			set -l attempts scan
			test "$argv[2]" != --scan; and set -q cached[1]; and set attempts cached scan
			for attempt in $attempts
				switch $attempt
					case cached
						set -f ports (path basename -E -- $cached)
						set -f timeout 2
					case scan
						# Some node listeners accept a connection and never reply, so the probe timeout stays short.
						set -f ports (lsof -nP -iTCP -sTCP:LISTEN -a -c node -Fn 2>/dev/null | string match -r '^n.*:(\d+)$' -g | sort -un)
						set -f timeout 0.5
				end
				command rm -rf $cache
				mkdir -p $cache
				set -q ports[1]; or continue
				curl -sf -m $timeout --parallel --parallel-max 100 -o "$cache/#1.json" "http://localhost:{"(string join , -- $ports)"}/api/state"
				for file in $cache/*.json
					jq -e .machinesRoot $file >/dev/null 2>&1; or command rm $file
				end
				set -l found $cache/*.json
				set -q found[1]; and break
			end

			set -l files $cache/*.json
			if not set -q files[1]
				printf '\t\t\t\t%s\n' 'No running cubefarm instances found. Start one with cubefarm.fish.'
				return
			end
			# Fields: port, repo id, PR number, PR url, then the padded display line.
			jq -nr '
				def pad($n): . + (" " * ($n - length));
				[inputs | (input_filename | split("/")[-1] | rtrimstr(".json")) as $port
					| .repos[] | .id as $id | .fullName as $repo | .pulls[] | select(.state == "OPEN")
					| {$port, $id, number, url, cols: [$port, $repo, "#\(.number)", .checks // "-", (.mergeable // "-" | ascii_downcase), (.title | gsub("\t"; " "))]}]
				| ([["INST", "REPO", "PR", "CHECKS", "MERGE", "TITLE"]] + map(.cols)) as $all
				| [range(5) as $i | $all | map(.[$i] | length) | max] as $w
				| def line: [range(5) as $i | .[$i] | pad($w[$i])] + [.[5]] | join("  ");
				("\t\t\t\t" + ($all[0] | line)),
				(.[] | [.port, .id, (.number | tostring), .url, (.cols | line)] | join("\t"))
			' $files

		case --preview
			test -f $cache/$argv[2].json; or return
			jq -r --arg repo $argv[3] --argjson pr $argv[4] '
				.repos[] | select(.id == $repo) | .defaultBranch as $base | .pulls[] | select(.number == $pr)
				| "#\(.number) \(.title)",
					"\(.headRefName) -> \($base)",
					.url,
					"",
					"checks     \(.checks // "-")",
					(.failedChecks[] | "  failed   \(.name)"),
					(.pendingChecks[] | "  pending  \(.name)"),
					"mergeable  \(.mergeable // "-") (\(.mergeState // "-"))",
					"review     \(.reviewDecision // "none")",
					"draft      \(if .isDraft then "yes" else "no" end)",
					"diff       +\(.additions) -\(.deletions)",
					"closes     \(.closesIssues | map("#\(.)") | join(", ") | if . == "" then "-" else . end)",
					"opened     \(.createdAt)"
			' $cache/$argv[2].json

		case ''
			set -f picked (_fzf_wrapper </dev/null --delimiter=\t --with-nth=5 --header-lines=1 --prompt='PR> ' \
				--header='enter: qa   ctrl-o: open in browser   ctrl-y: copy url   ctrl-r: rescan ports' \
				--bind='start:reload:cf --rows' \
				--bind='ctrl-r:reload:cf --rows --scan' \
				--bind='ctrl-o:execute-silent:open {4}' \
				--bind='ctrl-y:execute-silent:printf %s {4} | pbcopy' \
				--preview='cf --preview {1} {2} {3}')
			or return 1
			set -f fields (string split -- \t $picked)
			curl -sS -X POST http://localhost:$fields[1]/api/repos/(string replace -a / %2F -- $fields[2])/pulls/$fields[3]/qa
			echo

		case '*'
			echo "Usage: cf" >&2
			return 1
	end
end
