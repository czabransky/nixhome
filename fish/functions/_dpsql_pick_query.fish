function _dpsql_pick_query --description "Pick a query for CONTAINER USER DB via fzf: merges saved .dpsql/queries/*.sql files with generated select/count queries for every table in the public schema, or type a query inline. ctrl-g edits the result in \$EDITOR before running; ctrl-t/ctrl-o/ctrl-r filter to generated/saved/all. Prints the chosen SQL to stdout."
	set -f container $argv[1]
	set -f pg_user $argv[2]
	set -f pg_db $argv[3]

	set -f project_root (git rev-parse --show-toplevel 2>/dev/null)
	test -z "$project_root"; and set -f project_root (pwd)
	set -f queries_dir $project_root/.dpsql/queries

	set -f user_entries
	if test -d $queries_dir
		for file in (find $queries_dir -type f -name '*.sql' | sort)
			set -f --append user_entries user\t(path basename $file)\t$file
		end
	end

	set -f dynamic_entries
	set -f tables_query "select tablename from pg_catalog.pg_tables where schemaname = 'public' order by tablename;"
	for line in (docker exec -i $container psql -U $pg_user -d $pg_db --csv --tuples-only -c $tables_query 2>/dev/null)
		set -f table (string trim -- $line)
		test -z "$table"; and continue
		set -f --append dynamic_entries dynamic\t"$table (select *)"\t"select * from \"$table\";"
		set -f --append dynamic_entries dynamic\t"$table (count)"\t"select count(*) from \"$table\";"
	end

	set -f tmp_dir (mktemp -d)
	printf '%s\n' $user_entries >$tmp_dir/user.tsv
	printf '%s\n' $dynamic_entries >$tmp_dir/dynamic.tsv
	cat $tmp_dir/user.tsv $tmp_dir/dynamic.tsv >$tmp_dir/all.tsv

	set -f result (
		cat $tmp_dir/all.tsv | \
		_fzf_wrapper --print-query \
			--expect=ctrl-g \
			--delimiter=\t \
			--with-nth=2 \
			--prompt='Query> ' \
			--header='enter run · ctrl-g edit · ctrl-t tables only · ctrl-o saved only · ctrl-r all' \
			--preview='if test {1} = user; bat --style=plain --color=always {3} 2>/dev/null; or cat {3} 2>/dev/null; else; echo {3}; end' \
			--preview-window=right,60% \
			--bind "ctrl-t:reload(cat $tmp_dir/dynamic.tsv)" \
			--bind "ctrl-o:reload(cat $tmp_dir/user.tsv)" \
			--bind "ctrl-r:reload(cat $tmp_dir/all.tsv)"
	)

	rm -rf $tmp_dir

	set -f typed $result[1]
	set -f key $result[2]
	set -f selection $result[3..-1]

	set -f sql $typed
	if test (count $selection) -gt 0
		set -f entry_type (string split --field=1 -- \t $selection[1])
		set -f entry_content (string split --field=3 -- \t $selection[1])
		if test "$entry_type" = user
			set sql (cat $entry_content | string collect)
		else
			set sql $entry_content
		end
	end

	if test "$key" = ctrl-g
		set -f editor $EDITOR
		test -z "$editor"; and set -f editor vi

		set -f edit_dir (mktemp -d)
		set -f edit_file $edit_dir/query.sql
		printf '%s\n' $sql >$edit_file

		$editor $edit_file
		set sql (cat $edit_file | string collect)
		rm -rf $edit_dir
	end

	echo $sql
end
