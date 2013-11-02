. "$SMUX_ROOT/lib/command-helpers.sh"

shorthelp "Prints all files in a session's repository" "$@"


check_session "$@"

for file in "$repository"/*; do
	file="${file##*/}"
	[ "$file" = "*" ] && continue
	echo $file
done
