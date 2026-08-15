function dexec --description "Open an interactive shell in a docker container selected via fzf. Defaults to /bin/sh; pass a different command to run instead."
	set -f container (_docker_pick_container)
	if test -n "$container"
		if test (count $argv) -eq 0
			docker exec -it $container /bin/sh
		else
			docker exec -it $container $argv
		end
	end
end
