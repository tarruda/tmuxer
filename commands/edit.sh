. "$SMUX_ROOT/lib/command-helpers.sh"

shorthelp "Edit a script in the session repository" "$@"


check_session "$@"

if [ -z "$2" ]; then
	echo 'No script name was provided' >&2
	exit 1
fi

script="$location/$2"

$EDITOR "$script"
