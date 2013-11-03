. "$TMUXER_ROOT/lib/command-helpers.sh"

shorthelp "Prints registered sessions" "$@"

if [ -d "$TMUXER_CONFIG/sessions" ]; then
	for file in "$TMUXER_CONFIG/sessions"/*; do
		file="${file##*/}"
		[ "$file" = "*" ] && continue
		echo "$file"
	done
fi
