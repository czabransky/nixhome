function dlogs --description "Follow logs of a docker container selected via fzf. Extra args are passed through to docker logs."
	set -f container (_docker_pick_container)
	if test -n "$container"
		docker logs -f $argv $container
	end
end
