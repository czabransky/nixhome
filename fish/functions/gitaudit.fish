function gitaudit --description "Audit a file in git to see its change history. VISUAL: gitk $file"
	git log --pretty=format:%H -- $argv | _fzf_wrapper \
		--preview "git log -p -1 {} $argv | bat -n --color=always"
end
