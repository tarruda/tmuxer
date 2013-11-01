# Split a pane and set the splitted pane id to $pane_id
pane() {
	local opt
	local o_target
	local o_dir
	local args

	while getopts dt:c:PF: opt; do
		case $opt in
			t) o_target="$opt" ;;
			c) o_dir="$opt" ;;
		esac
	done

	shift $(expr $OPTIND - 1)

	[ -z "$o_target" ] && o_target="$pane_id"
	[ -z "$o_dir" ] && o_dir="$session_root"

	args="-P -F '#{pane_id}' -t $o_target"

	[ -n "$session_root" ] && args="$args -c '$o_dir'"

	pane_id=$(tmux split-window $args "$@")
}

# Create a new window with a name as argument. If no windows were created,
# this will start a session first
window() {
	local o_target
	local o_dir
	local args

	while getopts dt:c:PF: opt; do
		case $opt in
			t) o_target="$opt" ;;
			c) o_dir="$opt" ;;
		esac
	done

	shift $(expr $OPTIND - 1)

	[ -z "$o_target" ] && o_target="$pane_id"
	[ -z "$o_dir" ] && o_dir="$session_root"
	[ -n "$o_dir" ] && o_dir="$(cd "$o_dir" 2> /dev/null && pwd)"

	if [ -z "$session_id" ]; then
		# Session wasn't created yet, do it now
		args="-P -F '#{session_id}' -d -s '$session_name'"

		# Set the initial window name
		[ -n "$1" ] && args="$args -n '$1'"

		if [ -n "$o_dir" ]; then
			session_id="$(cd "$o_dir" && TMUX= tmux new-session $args)"
		fi

		if [ -n "$session_root" ]; then
			tmux set-option -t $session_id -q default-path "$session_root"
		else
			session_id="$(TMUX= tmux new-session $args)"
		fi

		window_id="$(tmux display -p -t $session_id '#{window_id}')"
		pane_id="$(tmux display -p -t $session_id '#{pane_id}')"
	else
		args="-P -F '#{window_id}'"

		[ -n "$1" ] && args="$args -n '$1'"

		window_id="$(tmux new-window $args)"
		pane_id="$(tmux display -p -t $session_id '#{pane_id}')"
	fi
}

# Send keys to the current pane or a pane specified with '-t'
send() {
	local opt
  local o_target

	while getopts t: opt; do
		case $opt in
			t) o_target="$opt" ;;
		esac
	done

	shift $(expr $OPTIND - 1)

	tmux send-keys -t "$o_target" "$@"
}

# Send a command(keys + return) to the current pane or a pane specified with
# '-t'
cmd() {
	local opt
  local o_target

	while getopts t: opt; do
		case $opt in
			t) o_target="$opt" ;;
		esac
	done

	shift $(expr $OPTIND - 1)

	[ -z "$o_target" ] && o_target="$pane_id"

	send -t "$o_target" -l "$@"
	send -t "$o_target" "C-m"
}

# Silently set option in the current session
setk() {
	tmux set-option -t $session_id -q "@$1" "$2"
}

# Get option in the current session
getk() {
	tmux show-options -t $session_id -v "@$1" 2> /dev/null
}

