. "$SMUX_ROOT/lib/command-helpers.sh"

shorthelp "Print registered sessions" "$@"

if [ -d "$SMUX_REPOSITORIES" ]; then
	for file in "$SMUX_REPOSITORIES"/*; do
		echo "${file##*/}"
	done
fi
