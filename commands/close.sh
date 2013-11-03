. "$TMUXER_ROOT/lib/command-helpers.sh"
. "$TMUXER_ROOT/lib/script-helpers.sh"

shorthelp "Shutdown session, invoking the teardown script if available" "$@"


if [ -n "$1" ]; then
	sessions="$1"
else
	sessions="$(sh $TMUXER_ROOT/commands/list-sessions.sh)"
fi

for name in $sessions; do
	check_session "$name"

	tmux has-session -t "$name" || continue

	if [ -r "$repository/teardown.sh" ]; then
		# For consistency with the setup script, populate {session,window,pane}_id
		# variables
		session_id="$(tmux display -p -t "$name" '#{session_id}')"
		window_id="$(tmux display -p -t "$name" '#{window_id}')"
		pane_id="$(tmux display -p -t "$name" '#{pane_id}')"

		. "$repository/teardown.sh"
	fi

	tmux kill-session -t "$name"
	echo "Session '$name' closed successfully"
done
