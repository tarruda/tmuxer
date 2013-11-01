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

