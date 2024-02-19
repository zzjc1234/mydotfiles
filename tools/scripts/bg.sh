#!/bin/zsh

LOCK_DIR="/tmp/my_script.lock"
SESSION_ID=$(date +%s)  # 获取唯一的会话ID

is_running() {
	local command="$1"
	pgrep "$command" > /dev/null
}

cleanup() {
  rmdir "$LOCK_DIR"
  exit
}

trap 'cleanup' HUP TERM EXIT

op=0

while [ "$op" -eq 0 ]; do
	if ! mkdir "$LOCK_DIR" 2>/dev/null; then
		op=0
	else
		op=1
	fi
  sleep 0.2
done

flag=0
pflag=0

while true; do
  if is_running "nvim" || is_running "glow" || is_running "lazygit" || is_running "taskwarrior-tui"; then
    flag=1
  else
    flag=0
  fi

  if [ "$flag" -eq 1 ] && [ "$pflag" -eq 0 ]; then
    kitty @ set-background-image ~/Desktop/Personal/black.jpg
  elif [ "$flag" -eq 0 ] && [ "$pflag" -eq 1 ]; then
    kitty @ set-background-image ~/Desktop/Personal/alena-aenami-bluehour-1k.png
  fi
  pflag="$flag"
  sleep 0.2
done

