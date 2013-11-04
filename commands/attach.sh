. "$TMUXER_ROOT/lib/command-helpers.sh"

shorthelp "Attaches to a tmux session or opens the selection menu" "$@"


if ! tmux attach > /dev/null 2>&1; then
	sh "$TMUXER_ROOT/commands/choose-session.sh"
fi
