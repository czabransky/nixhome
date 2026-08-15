function dps --description "Browse docker containers via fzf and print the selected container ID(s). Pass --all to include stopped containers."
	_docker_pick_container --multi $argv
end
