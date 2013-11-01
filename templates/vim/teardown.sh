# Get the vim pane id
vim_pane_id=$(getk vim-pane)

# Send escape to ensure vim is in normal mode
send -t $vim_pane_id "Escape"

# Write all buffers and quit vim
cmd -t $vim_pane_id ":wqa"
