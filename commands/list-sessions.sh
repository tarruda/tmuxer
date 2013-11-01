. "$SMUX_ROOT/lib/command-helpers.sh"

shorthelp "Print registered sessions" "$@"

if [ -d "$SMUX_REPOSITORIES" ]; then
	for file in "$SMUX_REPOSITORIES"/*; do
		file="${file##*/}"
		[ "$file" = "*" ] && continue
		echo "$file"
	done
fi
