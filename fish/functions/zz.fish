function zz --description "Run zoxide query in an fzf window"
	zoxide query --list $argv | _fzf_wrapper --ansi --border --reverse
end
