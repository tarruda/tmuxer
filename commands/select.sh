. "$TMUXER_ROOT/lib/command-helpers.sh"

shorthelp "Displays a menu to interactively select a session" "$@"

# Simple menu for switching/starting sessions. This needs the 'stty', 'tput',
# 'dd' and 'sed' utilities in your PATH

# update the screen
update() {
	cls=
	if [ $# -gt 0 ]; then
		cls=1
		tput cup 0 0
	fi
	tmp="$sessions"
	current=0
	line=0

	while [ ${#tmp} -gt 0 ]; do
		# move the cursor to the current line
		e="$(h "$tmp")"
		tmp="$(t "$tmp")"
		if [ $current -lt $display_start ]; then
			current=$((current + 1))
			continue
		fi
		if [ $current -gt $display_end ]; then
			break
		fi
		# Avoid needless screen flickering by only redrawing the updated lines
		if [ -n "$cls" ] || [ "$current" = "$selected" ] || [ "$current" = "$previous" ]; then
			tput cup $line 0    # move the cursor to the current line
			tput el             # clear to the end of line
			if [ "$current" = "$selected" ]; then
				echo "${hilight}-> $e${normal}"
			else
				echo "   $e"
			fi
		fi
		current=$((current + 1))
		line=$((line + 1))
	done
}
# get the numbers of lines/columns
lines=$(tput lines)
columns=$(tput cols)

# selected entry index
selected=0
display_start=0
display_end=$((lines - 1))

# sessions sessions
sessions=""

# added session ids
ids=""

# total number of sessions
count=0

# last opened session
[ -r "$TMUXER_CONFIG/last-session" ] &&\
 	last_session="$(cat "$TMUXER_CONFIG/last-session" 2> /dev/null)"

# Add 
tmp="$(sh "$TMUXER_ROOT/commands/list-sessions.sh")"
echo "$tmp"
while [ ${#tmp} -gt 0 ]; do
	e="$(h "$tmp")"
	tmp="$(t "$tmp")"
	# if [ "$e" = "$last_session" ]; then
	# 	selected=$count
	# fi
	# if session is running, add session id separated by colon
	if tmux has-session -t "$e" > /dev/null 2>&1; then
		id="$(tmux display -p -t "$e" '#{session_id}')"
		stat="(open, id = $id)"
	else
		stat="(closed)"
	fi
	e="$(printf "%-$((columns - 30))s %-25s" "$e" "$stat")"
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

if [ -n "$TMUX" ]; then
	running_session_id="\$${TMUX##*,}"
fi

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

		# if [ "$id" = "$running_session_id" ]; then
		# 	selected=$count
		# fi

		stat="(unmanaged, id = $id)"
		name="$(printf "%-$((columns - 30))s %-25s" "$name" "$stat")"
		if [ -n "$sessions" ]; then
			sessions="$sessions\n$name"
		else
			sessions="$name"
		fi
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
				if [ $selected -lt $display_start ]; then
					display_start=$((display_start - 1))
					display_end=$((display_end - 1))
					update 1
				else
					update
				fi
			fi
			;;
		"$down"|j)
			if [ $((selected)) -lt $((count - 1)) ]; then
				previous=$selected
				selected=$((selected + 1))
				if [ $selected -gt $display_end ]; then
					display_start=$((display_start + 1))
					display_end=$((display_end + 1))
					update 1
				else
					update
				fi
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

e="$(h $tmp)"


if [ $index -ge $unmanaged_index ]; then
	if [ -z "$TMUX" ]; then
		tmux attach-session -t "$e"
	else
		tmux switch-client -t "$e"
	fi
else
	sh "$TMUXER_ROOT/commands/open.sh" "$e"
fi
