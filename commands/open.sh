. "$TMUXER_ROOT/lib/command-helpers.sh"
. "$TMUXER_ROOT/lib/script-helpers.sh"

shorthelp "Attaches to a tmux session or starts a new one" "$@"


check_session "$@"

if ! tmux has-session -t "$name" > /dev/null 2>&1; then
	. "$repository/setup.sh"
	if [ -z "$session_id" ]; then
		echo "No windows were created" >&2
		exit 1
	fi
	echo "$name" > "$TMUXER_CONFIG/last-session"
fi

if [ -z "$TMUX" ]; then
	tmux attach-session -t "$name"
else
	tmux switch-client -t "$name"
fi
