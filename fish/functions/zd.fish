function zd --description "Remove the selected entry from zoxide"
	set -l dir ( zoxide query --list | fzf --ansi --border --reverse )
	zoxide remove $dir
	echo "$dir removed from zoxide"
end
