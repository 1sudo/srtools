#!/bin/bash

terminal=$(ps -o comm= -p "$(($(ps -o ppid= -p "$(($(ps -o sid= -p "$$")))")))")
tmp_file=/tmp/yakuake_tmp

if [ "$terminal" == "yakuake" ] && [ ! -f "$tmp_file" ]; then
	touch /tmp/yakuake_tmp
	$HOME/.scripts/split.sh
fi
