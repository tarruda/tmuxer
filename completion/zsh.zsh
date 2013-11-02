#compdef smux

local curcontext=$curcontext sessions state line 

if which smux &> /dev/null; then
	sessions=$(smux list-sessions)
	cmds=()
	smux list-commands | while read name desc; do
		cmds+="$name:$desc"
	done
fi

declare -A opt_args

if (( CURRENT == 2 )); then
	_describe -t commands 'Commands' cmds
elif (( CURRENT == 3 )); then
	case $words[2] in
		close|delete|edit|list-files|open)
			_arguments "2:Session:(${sessions})"
			;;
	esac
elif (( CURRENT == 4 )); then
	case $words[2] in
		edit)
			_arguments "3:Files:($(smux list-files $words[3]))"
		;;
	esac
fi
