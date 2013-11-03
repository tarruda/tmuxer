. "$TMUXER_ROOT/lib/command-helpers.sh"

shorthelp "Prints registered sessions" "$@"

if [ -d "$TMUXER_REPOSITORIES" ]; then
	for file in "$TMUXER_REPOSITORIES"/*; do
		file="${file##*/}"
		[ "$file" = "*" ] && continue
		echo "$file"
	done
fi
