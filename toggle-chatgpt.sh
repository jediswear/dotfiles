#!/bin/bash

CLASS="chrome-chatgpt.com__-Default"
WINDOW_JSON=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\")")

if [ -z "$WINDOW_JSON" ]; then
  omarchy-launch-webapp "https://chatgpt.com"
  exit 0
fi

WORKSPACE=$(echo "$WINDOW_JSON" | jq -r '.workspace.name')
ADDRESS=$(echo "$WINDOW_JSON" | jq -r '.address')

if [[ "$WORKSPACE" == special:* ]]; then
  # Hidden in scratchpad → bring to current workspace and focus
  ACTIVE_WS_ID=$(hyprctl activeworkspace -j | jq -r '.id')
  hyprctl dispatch movetoworkspace "$ACTIVE_WS_ID,address:$ADDRESS"
  hyprctl dispatch focuswindow "address:$ADDRESS"
else
  # Visible → send to scratchpad (hides it)
  hyprctl dispatch movetoworkspacesilent "special:chatgpt,address:$ADDRESS"
fi