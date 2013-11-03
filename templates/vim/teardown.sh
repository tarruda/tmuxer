# Get the vim pane id
vim_pane_id=$(geto vim-pane 2> /dev/null)

if [ -n "$vim_pane_id" ]; then
	# Send escape to ensure vim is in normal mode
	send -t $vim_pane_id "Escape"

	# Write all buffers and quit vim
	cmd -t $vim_pane_id ":wqa"
fi
