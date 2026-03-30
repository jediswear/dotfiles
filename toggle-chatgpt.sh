#!/bin/bash

if hyprctl clients | grep -q "chrome-chatgpt.com__-Default"; then
  hyprctl dispatch closewindow "class:^(chrome-chatgpt.com__-Default)$"
else
  omarchy-launch-webapp "https://chatgpt.com"
fi