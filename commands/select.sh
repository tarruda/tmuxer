. "$SMUX_ROOT/lib/command-helpers.sh"

shorthelp "Displays a menu to interactively select a session" "$@"

# Simple menu for switching/starting sessions. This needs the 'stty', 'tput',
# 'dd' and 'sed' utilities in your PATH

# update the screen
update() {
	cls=
	if [ $# -gt 0 ]; then
		cls=1
	fi
	tmp="$sessions"
	current=0

	while [ ${#tmp} -gt 0 ]; do
		# move the cursor to the current line
		e="$(h "$tmp")"
		tmp="$(t "$tmp")"
		# Avoid needless screen flickering by only redrawing the updated lines
		if [ -n "$cls" ] || [ "$current" = "$selected" ] || [ "$current" = "$previous" ]; then
			tput cup $current 0 # move the cursor to the current line
			tput el             # clear to the end of line
			if [ "$current" = "$selected" ]; then
				echo "${hilight}-> $e${normal}"
			else
				echo "   $e"
			fi
		fi
		current=$((current + 1))
	done
}

# selected entry index
selected=0

# sessions sessions
sessions=""

# added session ids
ids=""

# total number of sessions
count=0
tmp="$(smux list-sessions)"
while [ ${#tmp} -gt 0 ]; do
	e="$(h "$tmp")"
	tmp="$(t "$tmp")"
	id="$(tmux display -p -t "$e" '#{session_id}')"
	# if session is running, add session id separated by colon
	if tmux has-session -t "$e" 2> /dev/null; then
		stat="(open, id = $id)"
	else
		stat="(closed)"
	fi
	stat="$(printf "%-25s" "$stat")"
	e="$(printf "%-$((columns - 30))s %s" "$e" "$stat")"
	if [ -n "$sessions" ]; then
		sessions="$sessions\n$e"
	else
		sessions="$e"
	fi
	ids="$ids $id"
	count=$((count + 1))
done

unmanaged_index=$count
running="$(tmux list-sessions -F '#{session_name}:#{session_id}')"

set $ids
while [ ${#running} -gt 0 ]; do
	e="$(h "$running")"
	running="$(t "$running")"
	id="${e##*:}"
	name="${e%:*}"
	found=
	for i in $*; do
		[ "$i" = "$id" ] && found=1 && break
	done
	if [ -z "$found" ]; then
		stat="(unmanaged, id = $id)"
		stat="$(printf "%-25s" "$stat")"
		name="$(printf "%-$((columns - 30))s %s" "$name" "$stat")"
		sessions="$sessions\n$name"
		count=$((count + 1))
	fi
done

if [ $count -eq 0 ]; then
	echo 'No sessions are registered or running' >&2
	exit 1
fi

trap "exit 1" INT TERM
# ensure the terminal is restored on exit
trap "tput cnorm; tput clear; tput cup 0 0" EXIT
# erase cursor
tput civis

# get the numbers of lines/columns
lines=$(tput lines)
columns=$(tput cols)

# hilight=$(tput smso)
# normal=$(tput rmso)
hilight="$(tput setb 6)$(tput setf 0)"
normal="$(tput sgr0)"
tput clear

update 1

while true; do
	rkey
	case $REPLY in
		"$up"|k)
			if [ $((selected)) -gt 0 ]; then
				previous=$selected
				selected=$((selected - 1))
				update
			fi
			;;
		"$down"|j)
			if [ $((selected)) -lt $((count - 1)) ]; then
				previous=$selected
				selected=$((selected + 1))
				update
			fi
			;;
		"$lf")
			break
			;;
	esac
done

tput clear

tmp="$sessions"
index="$selected"

while [ $selected -ge 1 ]; do
	e="$(h "$tmp")"
	tmp="$(t "$tmp")"
	selected=$((selected - 1))
done

e=$(h $tmp)


if [ $index -ge $unmanaged_index ]; then
	if [ -z "$TMUX" ]; then
		tmux attach-session -t "$e"
	else
		tmux switch-client -t "$e"
	fi
else
	smux open "$e"
fi
