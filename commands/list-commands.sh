. "$TMUXER_ROOT/lib/command-helpers.sh"

shorthelp "Prints available commands with short help" "$@"

for file in "$TMUXER_ROOT/commands"/*.sh; do
	cmd="${file##*/}"
	cmd="${cmd%.sh}"
	cmd="$(printf "%-15s" "$cmd")"
	help="$(sh "$file" "--shorthelp")"
	echo "$cmd $help"
done
