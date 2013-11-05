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
		e="${tmp%%,*}"
		tmp="${tmp#*,}"
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
			e="$(printf "%-$((columns - 6))s" "$e")"
			if [ "$current" = "$selected" ]; then
				echo "${hilight}(${current})  $e${normal}"
			else
				echo "(${current})  $e"
			fi
		fi
		current=$((current + 1))
		line=$((line + 1))
	done
}

choose_outside_tmux() {
	# Create an interactive menu similar to choose-session that will display
	# the list of sessions(open and closed) for the user to select

	# get the numbers of lines/columns
	lines=$(tput lines)
	columns=$(tput cols)

	display_start=0
	display_end=$((lines - 1))

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

	while [ $selected -ge 0 ]; do
		e="${tmp%%,*}"
		tmp="${tmp#*,}"
		selected=$((selected - 1))
	done

	sh "$TMUXER_ROOT/commands/open.sh" "$e"
}

choose_inside_tmux() {
	# Use tmux builtin 'choose-list' to display an interactive menu that will
	# call the 'open' command
	if [ $selected -gt 0 ]; then
		keys=''
		while [ $selected -gt 0 ]; do
			keys="$keys Down"
			selected=$((selected - 1))
		done
		tmux choose-list -l "$sessions" "run-shell \"TMUXER_ROOT='$TMUXER_ROOT'\
			TMUXER_CONFIG='$TMUXER_CONFIG'\
		 	sh '$TMUXER_ROOT/commands/open.sh' '%%'\"" \; send-keys $keys
	else
		tmux choose-list -l "$sessions" "run-shell \"TMUXER_ROOT='$TMUXER_ROOT'\
			TMUXER_CONFIG='$TMUXER_CONFIG' sh '$TMUXER_ROOT/commands/open.sh' '%%'\""
	fi
}

format_sessions

if [ -z "$TMUX" ]; then
	choose_outside_tmux
else
	choose_inside_tmux
fi
