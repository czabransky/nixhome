function zd --description "Remove the selected entry from zoxide"
	$dir = zoxide query --list $argv | fzf --ansi --border --reverse
	zoxide remove $dir
end
