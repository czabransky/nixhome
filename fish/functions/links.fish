function links --description "Pick a link from ~/Links.md via fzf and open it in the default browser"
	set -f links_file $HOME/Links.md
	if not test -f $links_file
		echo "links: $links_file not found" >&2
		return 1
	end

	set -f selection (
		string match -rv '^\s*(#.*)?$' <$links_file | \
		_fzf_wrapper \
			--delimiter='\s*\|\s*' \
			--with-nth=1 \
			--prompt='Links> ' \
			--preview='echo {2}' \
			--preview-window=down,3,wrap
	)

	test -z "$selection"; and return 0

	set -f url (string split --field=2 -- '|' $selection)
	open (string trim -- $url)
end
