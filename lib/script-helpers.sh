# Split a pane and set the splitted pane id to $pane_id
pane() {
	if [ -z "$session_id" ]; then
		echo 'Create a window first' >&2
		exit 1
	fi

	local opt
	local o_target
	local o_dir
	local o_percentage
	local o_size
	local o_horizontal
	local args

	while getopts dt:c:PF:hp:l: opt; do
		case $opt in
			t) o_target="$OPTARG" ;;
			c) o_dir="$OPTARG" ;;
			p) o_percentage="$OPTARG" ;;
			l) o_size="$OPTARG" ;;
			h) o_horizontal=1 ;;
		esac
	done

	shift $(expr $OPTIND - 1)

	[ -z "$o_target" ] && o_target="$pane_id"
	[ -z "$o_dir" ] && o_dir="$session_root"

	[ -n "$o_horizontal" ] && args="-h"
	[ -n "$o_dir" ] && args="$args -c '$o_dir'"
	args="$args -P -F '#{pane_id}'"
	[ -n "$o_percentage" ] && args="$args -p $o_percentage"
	[ -n "$o_size" ] && args="$args -l $o_size"
	args="$args -t '$o_target'"

	pane_id=$(eval "tmux split-window $args" "$@")
}

# Create a new window with a name as argument. If no windows were created,
# this will start a session first
window() {
	local opt
	local o_dir
	local o_name
	local args

	while getopts dt:c:n: opt; do
		case $opt in
			c) o_dir="$OPTARG" ;;
			n) o_name="$OPTARG" ;;
		esac
	done

	shift $(expr $OPTIND - 1)

	[ -z "$o_dir" ] && o_dir="$session_root"

	if [ -n "$o_dir" ]; then
		# force tilde expansions
		eval o_dir="$o_dir"
		if [ ! -d "$o_dir" ]; then
			echo "'$o_dir' doesn't exist" >&2
			exit 1
		fi
	 	o_dir="$(cd "$o_dir" 2> /dev/null && pwd)"
	fi

	if [ -z "$session_id" ]; then
		# Session wasn't created yet, do it now
		args="-d -P -F '#{session_id}' -s '$name'"

		# Set the initial window name
		[ -n "$o_name" ] && args="$args -n '$o_name'"

		if [ -n "$o_dir" ]; then
			session_id="$(cd "$o_dir" && eval "TMUX= tmux new-session $args" "$@")"
		else
			session_id="$(eval "TMUX= tmux new-session $args" "$@")"
		fi

		if [ -n "$session_root" ]; then
			tmux set-option -t "$session_id" -q default-path "$session_root"
		fi

		window_id="$(tmux display -p -t "$session_id" '#{window_id}')"
		pane_id="$(tmux display -p -t "$session_id" '#{pane_id}')"
	else
		args="-P"
		[ -n "$o_dir" ] && args="$args -c '$o_dir'"
	 	args="$args -F '#{window_id}'"
		[ -n "$o_name" ] && args="$args -n '$o_name'"
		args="$args -t '${session_id}'"

		window_id="$(eval "tmux new-window $args" "$@")"
		pane_id="$(tmux display -p -t "$session_id" '#{pane_id}')"
	fi
}

# Send keys to the current pane or a pane specified with '-t'
send() {
	if [ -z "$session_id" ]; then
		echo 'Create a window first' >&2
		exit 1
	fi

	local opt
  local o_target
	local rest

	while getopts t:lR opt; do
		case $opt in
			t) o_target="$OPTARG" ;;
			*) rest="$rest -$opt $OPTARG"
		esac
	done

	shift $(expr $OPTIND - 1)

	tmux send-keys $rest -t "$o_target" "$@"
}

# Send a command(keys + return) to the current pane or a pane specified with
# '-t'
cmd() {
	if [ -z "$session_id" ]; then
		echo 'Create a window first' >&2
		exit 1
	fi

	local opt
  local o_target
	local rest

	while getopts t:R opt; do
		case $opt in
			t) o_target="$OPTARG" ;;
			*) rest="$rest -$opt $OPTARG"
		esac
	done

	shift $(expr $OPTIND - 1)

	[ -z "$o_target" ] && o_target="$pane_id"

	send -t "$o_target" -l "$@"
	send -t "$o_target" "C-m"
}

# Silently set option in the current session
seto() {
	if [ -z "$session_id" ]; then
		echo 'Create a window first' >&2
		exit 1
	fi

	tmux set-option -t "$session_id" -q "@$1" "$2"
}

# Get option in the current session
geto() {
	if [ -z "$session_id" ]; then
		echo 'Create a window first' >&2
		exit 1
	fi

	tmux show-options -t "$session_id" -v "@$1" 2> /dev/null
}

