. "$TMUXER_ROOT/lib/command-helpers.sh"

shorthelp "Create and register a new session" "$@"


while getopts t:d: optl; do
	case $opt in
		t) o_template="$opt" ;;
		r) o_repository="$opt" ;;
	esac
done

shift $(expr $OPTIND - 1)

if [ -z "$1" ]; then
	echo 'Need a session name' >&2
	exit 1
fi

name="$1"
location="$TMUXER_REPOSITORIES/$name"

if [ -e "$location" ]; then
	echo "Session '$name' already exists" >&2
	exit 1
fi

[ -z "$o_repository" ] && o_repository="$location" && default_repo=1
[ -z "$o_template" ] && o_template="vim"

template_dir="$TMUXER_ROOT/templates/$o_template"

if [ ! -d "$template_dir" ]; then
	echo "Template '$o_template' not found" >&2
	exit 1
fi

mkdir "$o_repository"

for file in "$template_dir"/*; do
	out="${file##*/}"
	cp -a "$file" "$o_repository/$out"
done

$EDITOR "$o_repository/setup.sh"

# If the session repository is not on standard location, create a file
# that contains the correct directory
[ -z "$default_repo" ] && echo "$o_repository" > "$location"

echo "Session '$name' was created successfully"
