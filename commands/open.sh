. "$TMUXER_ROOT/lib/command-helpers.sh"
. "$TMUXER_ROOT/lib/script-helpers.sh"

shorthelp "Attaches to a tmux session or starts a new one" "$@"

# extract the session name if invoked from 'select'
name="${1%%[(]*}"

# remove trailing spaces
name="$(echo "$name" | sed -e 's/\s*$//')"

if ! tmux has-session -t "$name" 2> /dev/null; then
	check_session "$@"
	. "$repository/setup.sh"
	if [ -z "$session_id" ]; then
		echo "No windows were created" >&2
		exit 1
	fi
fi

echo "$name" > "$TMUXER_CONFIG/last-session"

if [ -z "$TMUX" ]; then
	tmux attach-session -t "$name"
else
	tmux switch-client -t "$name"
fi
