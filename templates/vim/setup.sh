# Basic scripted session template for writing some code with vim. 
#
# To edit this file later:
#     $ tmuxer edit [scripted session name] setup.sh
#
# To edit the teardown script:
#     $ tmuxer edit [scripted session name] teardown.sh

# If you want the session to have a default directory, set the session_root
# variable first
# session_root="~/my-cool-software-project"

# Create the main window and set its name to 'editor'
window -n editor

# Create a pane at the bottom with 75% of window height. This is where you will
# be running vim
pane -p 75

# Vim has a session persistence system, initialize vim with a command to
# persist its session in the session repository
vim_session="$repository/session.vim"
setup_cmd='mksession! $VIM_SESSION'

# If the vim session file exists, load the session instead of saving
if [ -e "$vim_session" ]; then
	setup_cmd='so $VIM_SESSION'
fi

# When vim exits, save the session back to the file
teardown_cmd='au VimLeavePre * mksession! $VIM_SESSION'

# Open vim passing its startup commands as -c arguments
cmd "VIM_SESSION='${vim_session}' vim -c '${setup_cmd}' -c '${teardown_cmd}'"

# Save the vim pane id as a tmux session option. This will be used to
# gracefully shutdown vim later. To edit the teardown script, enter
seto vim-pane $pane_id
