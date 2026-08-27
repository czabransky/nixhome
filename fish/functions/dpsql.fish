function dpsql --description "Run a SQL query against a postgres docker container and view the result as a nu table. With no query argument, pick a saved query from .dpsql/queries or type one inline. Pass -U/--user and -d/--db to override the container's POSTGRES_USER/POSTGRES_DB."
	argparse 'U/user=' 'd/db=' -- $argv
	or return 1

	set -f container (_docker_pick_container)
	test -z "$container"; and return 1

	set -f query
	if test (count $argv) -gt 0
		set query (string join ' ' -- $argv)
	else
		set query (_dpsql_pick_query | string collect)
	end

	if test -z "$query"
		echo "dpsql: no query given" >&2
		return 1
	end

	set -f pg_user $_flag_user
	test -z "$pg_user"; and set -f pg_user (docker exec $container printenv POSTGRES_USER 2>/dev/null)
	test -z "$pg_user"; and set -f pg_user postgres

	set -f pg_db $_flag_db
	test -z "$pg_db"; and set -f pg_db (docker exec $container printenv POSTGRES_DB 2>/dev/null)
	test -z "$pg_db"; and set -f pg_db $pg_user

	docker exec -i $container psql -U $pg_user -d $pg_db -c $query --csv | nu --stdin -c '$in | from csv | table'
end
