#!/usr/bin/env bash
# dual-terminal.sh - Pi shell on top, Ubuntu VM below, in one tmux session.
# Usage: ./dual-terminal.sh [start|stop|status]   (default: start)

SESSION="linux"

start() {
  if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    # Top pane: this Pi's own shell
    tmux new-session -d -s "$SESSION" -n main
    tmux set-option -p -t "$SESSION:main.0" allow-set-title off
    tmux select-pane -t "$SESSION:main.0" -T "Raspberry Pi"

    # Bottom pane: ssh to the VM; if ssh ends, keep the pane open with a shell
    tmux split-window -v -t "$SESSION:main" \
      "ssh vm; echo; echo 'VM connection closed. Type: ssh vm'; exec bash"
    tmux set-option -p -t "$SESSION:main.1" allow-set-title off
    tmux select-pane -t "$SESSION:main.1" -T "Ubuntu VM"

    # Settings for THIS session only (no ~/.tmux.conf changes)
    tmux set-option -t "$SESSION" mouse on
    tmux set-option -w -t "$SESSION:main" pane-border-status top
    tmux set-option -w -t "$SESSION:main" pane-border-lines single
    tmux set-option -w -t "$SESSION:main" pane-border-style fg=green
    tmux set-option -w -t "$SESSION:main" pane-active-border-style fg=brightgreen
    tmux set-option -w -t "$SESSION:main" pane-border-format " #{pane_title} "

    tmux select-pane -t "$SESSION:main.0"
  fi

  # Attach only if we're in a real terminal
  if [ -t 1 ]; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$SESSION"
    else
      tmux attach-session -t "$SESSION"
    fi
  else
    echo "Session '$SESSION' is running (no terminal to attach to)."
    status
  fi
}

stop() {
  if tmux kill-session -t "$SESSION" 2>/dev/null; then
    echo "Stopped session '$SESSION'."
  else
    echo "No session '$SESSION' running."
  fi
}

status() {
  tmux list-panes -t "$SESSION:main" \
    -F '#{pane_index}: #{pane_title} -> #{pane_current_command}' 2>/dev/null \
    || echo "No session '$SESSION' running."
}

case "${1:-start}" in
  start)  start ;;
  stop)   stop ;;
  status) status ;;
  *) echo "Usage: $0 [start|stop|status]"; exit 1 ;;
esac
