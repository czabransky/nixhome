function _dpsql_pick_query --description "Pick a saved .sql query from <project root>/.dpsql/queries via fzf, or type a query inline if nothing is selected. Prints the chosen SQL to stdout."
	set -f project_root (git rev-parse --show-toplevel 2>/dev/null)
	test -z "$project_root"; and set -f project_root (pwd)

	set -f queries_dir $project_root/.dpsql/queries
	set -f files
	test -d $queries_dir; and set -f files (find $queries_dir -type f -name '*.sql' | sort)

	set -f entries
	for file in $files
		set -f --append entries $file\t(path basename $file)
	end

	set -f result (
		printf '%s\n' $entries | \
		_fzf_wrapper --print-query \
			--delimiter=\t \
			--with-nth=2 \
			--prompt='Query> ' \
			--header='pick a saved query, or type one and press enter to run it as-is' \
			--preview='bat --style=plain --color=always {1} 2>/dev/null; or cat {1} 2>/dev/null' \
			--preview-window=right,60%
	)

	if test (count $result) -gt 1
		cat (string split --field=1 -- \t $result[2])
	else
		echo $result[1]
	end
end
