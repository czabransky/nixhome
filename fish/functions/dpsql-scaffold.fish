function dpsql-scaffold --description "Write a `select * from <table>` query file into .dpsql/queries for every table in the target postgres db's public schema. Skips tables that already have a query file; pass -f/--force to overwrite. -U/--user and -d/--db override; otherwise falls back to the container's APP_USER/APP_DB (if set), then POSTGRES_USER/POSTGRES_DB."
	argparse 'U/user=' 'd/db=' 'f/force' -- $argv
	or return 1

	set -f container (_docker_pick_container)
	test -z "$container"; and return 1

	set -f pg_user $_flag_user
	test -z "$pg_user"; and set -f pg_user (docker exec $container printenv APP_USER 2>/dev/null)
	test -z "$pg_user"; and set -f pg_user (docker exec $container printenv POSTGRES_USER 2>/dev/null)
	test -z "$pg_user"; and set -f pg_user postgres

	set -f pg_db $_flag_db
	test -z "$pg_db"; and set -f pg_db (docker exec $container printenv APP_DB 2>/dev/null)
	test -z "$pg_db"; and set -f pg_db (docker exec $container printenv POSTGRES_DB 2>/dev/null)
	test -z "$pg_db"; and set -f pg_db $pg_user

	set -f tables_query "select tablename from pg_catalog.pg_tables where schemaname = 'public' order by tablename;"
	set -f raw (docker exec -i $container psql -U $pg_user -d $pg_db --csv --tuples-only -c $tables_query)

	set -f tables
	for line in $raw
		set -f trimmed (string trim -- $line)
		test -n "$trimmed"; and set -f --append tables $trimmed
	end

	if test (count $tables) -eq 0
		echo "dpsql-scaffold: no tables found in schema 'public' of db '$pg_db'" >&2
		return 1
	end

	set -f project_root (git rev-parse --show-toplevel 2>/dev/null)
	test -z "$project_root"; and set -f project_root (pwd)

	set -f queries_dir $project_root/.dpsql/queries
	mkdir -p $queries_dir

	set -f written 0
	set -f skipped 0
	for table in $tables
		set -f query_file $queries_dir/$table.sql
		if test -e $query_file; and not set --query _flag_force
			set -f skipped (math $skipped + 1)
			continue
		end
		echo "select * from \"$table\";" >$query_file
		set -f written (math $written + 1)
	end

	echo "dpsql-scaffold: wrote $written, skipped $skipped (already existed) in "(path basename $queries_dir)
end
