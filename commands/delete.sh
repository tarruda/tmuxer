. "$SMUX_ROOT/lib/command-helpers.sh"

shorthelp "Remove a registered session" "$@"


check_session "$@"


if [ -d "$location" ]; then
	echo "The directory '$location' will be deleted!"
fi

echo -n "Are you sure you want to remove '$name'? (y/N) "
rkey

if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
	rm -rf "$location"
	echo
	echo "Session '$name' was deleted successfully"
	if [ "$repository" != "$location" ]; then
		if [ -d "$repository" ]; then
			echo "The repository location '$repository' will not be touched"
		else
			echo "The repository location '$repository' doesn't exist"
		fi
	fi
else
	echo
	echo "Session '$name' was not removed"
fi
