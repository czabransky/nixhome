function cf-retest --description "Queue a cubefarm PR for QA, which hands it to a developer first if it conflicts with the base branch. Usage: cf-retest PR [OWNER/REPO] [PORT], defaults czabransky/research and 4330"
	if test (count $argv) -lt 1
		echo "Usage: cf-retest PR [OWNER/REPO] [PORT]" >&2
		return 1
	end

	set -f pr $argv[1]
	set -f repo czabransky/research
	set -q argv[2]; and set -f repo $argv[2]
	set -f port 4330
	set -q argv[3]; and set -f port $argv[3]

	curl -sS -X POST http://localhost:$port/api/repos/(string replace -a / %2F -- $repo)/pulls/$pr/qa
	echo
end
