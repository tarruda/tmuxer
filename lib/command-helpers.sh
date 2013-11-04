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

format_sessions() {
	local window_id
	local tmp
	local e
	local id
	local ids
	local stat
	local running
	local last_session
	local running_session_id

	[ -r "$TMUXER_CONFIG/last-session" ] &&\
		last_session="$(cat "$TMUXER_CONFIG/last-session" 2> /dev/null)"
	[ -n "$TMUX" ] &&\
		running_session_id="\$${TMUX##*,}"

	count=0
	sessions=""
	window_id=$(tmux display -p '#{window_id}')
	tmp="$(sh "$TMUXER_ROOT/commands/list-sessions.sh")"
	while [ ${#tmp} -gt 0 ]; do
		e="$(h "$tmp")"
		tmp="$(t "$tmp")"

		[ "$e" = "$last_session" ] && selected=$count
		# if session is running, add session id
		if tmux has-session -t "$e" > /dev/null 2>&1; then
			id="$(tmux display -p -t "$e" '#{session_id}')"
			stat="(open) (id: $id)"
			[ "$id" = "$running_session_id" ] && selected=$count
		else
			stat="(closed)"
		fi
		e="$(printf "%-25s %s" "$e" "$stat")"
		sessions="$sessions$e,"
		ids="$ids $id"
		count=$((count + 1))
	done

	running="$(tmux list-sessions -F '#{session_name}:#{session_id}')"

	while [ ${#running} -gt 0 ]; do
		e="$(h "$running")"
		running="$(t "$running")"
		id="${e##*:}"
		name="${e%:*}"
		found=
		for i in $ids; do
			[ "$i" = "$id" ] && found=1 && break
		done
		if [ -z "$found" ]; then
			[ "$id" = "$running_session_id" ] && selected=$count
			stat="(unmanaged) (id: $id)"
			name="$(printf "%-25s %s" "$name" "$stat")"
			sessions="$sessions$name,"
			count=$((count + 1))
		fi
	done
}
