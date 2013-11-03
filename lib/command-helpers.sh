# Set some byte sequences to global variables for easy reuse
esc="$(printf '\33')"
lf="$(printf '\n')"
null="$(printf '\0')"
up="$(tput kcuu1)"
down="$(tput kcud1)"

shorthelp() {
	local arg
	for arg in $*; do
		if [ "$arg" = "--shorthelp" ]; then
			echo "$1"
			exit
		fi
	done
}

# Read a single key from terminal
rkey() {
	local settings k
	settings="$(stty --save)"
	stty -echo -icanon min 1
	REPLY="$(dd count=1 bs=1 2>/dev/null)"
	if [ "$REPLY" = "$esc" ]; then
		# probably up/down arrows, read the remaining chars
		k="$(dd count=2 bs=1 2>/dev/null)"
		REPLY="${REPLY}${k}"
	fi
	stty "$settings"
}

# extract the first line of a string
h() {
	echo "$1" | sed -n "1p"
}

# remove the first line of a string
t() {
	echo "$1" | sed "1d"
}

check_session() {
	if [ -z "$1" ]; then
		echo 'No session name was provided' >&2
		exit 1
	fi

	name="$1"
	location="$TMUXER_CONFIG/sessions/$name"

	if [ ! -e "$location" ]; then
		echo "Session '$name' doesn't exist"
		exit 1
	fi

	repository="$location"

	if [ -f "$location" ]; then
		if [ -r "$location" ]; then
			repository="$(cat "$location")"
		else
			echo "Cannot read '$location'" >&2
			exit 1
		fi
	fi

	if [ ! -d "$repository" ]; then
		echo "Repository for '$name' is not a directory"
		exit 1
	fi
}
