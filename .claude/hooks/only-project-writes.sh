#!/bin/bash
# Block Edit/Write/NotebookEdit outside the session's project dir.
input=$(cat)
path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input")
[ -z "$path" ] && exit 0
root=$(realpath "$CLAUDE_PROJECT_DIR")
abs=$(realpath -m "$path")
case "$abs/" in "$root"/*) exit 0 ;; esac
# Allow Claude's per-project memory folders.
case "$abs" in "$HOME"/.claude/projects/*/memory/*) exit 0 ;; esac
echo "Blocked: writes outside $root are not allowed ($abs)" >&2
exit 2
