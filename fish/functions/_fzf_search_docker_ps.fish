function _fzf_search_docker_ps --description "Search running docker containers. Replace the current token with the id(s) of the selected container(s)."
	set -f containers_selected (
		docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}' | \
		_fzf_wrapper --multi \
					--prompt='Docker> ' \
					--query (commandline --current-token) \
					--delimiter=\t \
					--with-nth=2,3,4 \
					--header='NAME	IMAGE	STATUS' \
					--preview='docker logs --tail 200 {1} 2>&1' \
					--preview-window='bottom:70%:wrap:follow' \
					$fzf_docker_ps_opts
	)

	if test $status -eq 0
		for container in $containers_selected
			set -f --append ids_selected (string split --field=1 -- \t $container)
		end
		commandline --current-token --replace -- (string join ' ' $ids_selected)
	end

	commandline --function repaint
end
