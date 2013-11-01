. "$SMUX_ROOT/lib/command-helpers.sh"

shorthelp "Remove a registered scripted session" "$@"


if [ -z "$1" ]; then
	echo 'Need a session name' >&2
	exit 1
fi

name="$1"
location="$SMUX_REPOSITORIES/$name"

if [ ! -e "$location" ]; then
	echo "Session '$name' doesn't exist"
	exit 1
fi

if [ -d "$location" ]; then
	echo "The directory '$location' will be deleted!"
	echo -n "Are you sure you want to remove '$name'? (y/N) "
elif [ -r "$location" ]; then
	repository="$(cat "$location")"
	echo -n "Are you sure you want to remove '$name'? (y/N) "
else
	echo "Cannot read '$location'" >&2
	exit 1
fi

rkey

if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
	rm -rf "$location"
	echo
	echo "Session '$name' was deleted successfully"
	if [ -n "$repository" ]; then
		if [ -d "$repository" ]; then
			echo "Remove '$repository' manually if you want to completely delete the session"
		else
			echo "Repository location '$repository' doesn't exist"
		fi
	fi
else
	echo
	echo "Session '$name' was not removed"
fi
