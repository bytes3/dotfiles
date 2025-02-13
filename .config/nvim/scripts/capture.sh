#!/usr/bin/env bash

pattern="$1"

function capture_all_panes() {
    local pane captured
    captured=""

    # Gather identifiers of all panes in the current session
    # The format: session_name:window_index.pane_index
    for pane in $(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}"); do
        # Capture the contents of the pane
        # -p: print the contents
        # (No -J or -S arguments here; if you want more scrollback, 
        #  you may specify them. For now, we capture the full current screen.)
        captured+="$(tmux capture-pane -p -t "$pane")"
        captured+=$'\n'
    done

    # Filter the output to attempt to find file paths.
    # This regex attempts to capture Unix-like paths. You may tweak it if needed.
    # It looks for sequences of alphanumeric, underscore, hyphen, or dot characters 
    # separated by slashes, forming a path structure.
    echo "$captured" | grep -oiE "[\/]([a-zA-Z0-9._-]+[\/])+[a-zA-Z0-9._-]+" | grep "$pattern"
}

capture_all_panes

