function dstop --description "Stop one or more docker containers selected via fzf"
	set -f containers (_docker_pick_container --multi)
	if test -n "$containers"
		docker stop $containers
	end
end
