function _docker_pick_container --description "Pick one or more docker containers via fzf and print their IDs, one per line. Pass --all to include stopped containers and --multi to allow selecting more than one."
	argparse a/all m/multi -- $argv

	set -f ps_args ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'
	set --query _flag_all; and set -f --append ps_args --all

	set -f fzf_args \
		--delimiter=\t \
		--with-nth=2,3,4 \
		--header='NAME	IMAGE	STATUS' \
		--prompt='Containers> ' \
		--preview='docker logs --tail 200 {1} 2>&1' \
		--preview-window=bottom:70%:wrap:follow
	set --query _flag_multi; and set -f --append fzf_args --multi

	set -f containers_selected (docker $ps_args | _fzf_wrapper $fzf_args)

	if test $status -eq 0
		for line in $containers_selected
			echo (string split --field=1 -- \t $line)
		end
	end
end
