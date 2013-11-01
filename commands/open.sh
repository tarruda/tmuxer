. "$SMUX_ROOT/lib/command-helpers.sh"
. "$SMUX_ROOT/lib/script-helpers.sh"

shorthelp "Attaches to a tmux session or starts a new one" "$@"


check_session "$@"

if ! tmux has-session -t "$name" > /dev/null 2>&1; then
	. "$repository/setup.sh"
fi

if [ -z "$TMUX" ]; then
	tmux attach-session -t "$name"
else
	tmux switch-client -t "$name"
fi
