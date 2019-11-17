#!/bin/bash

scripts_path=$HOME/.scripts/

# Get list of terminals
terminals=$(cat "$scripts_path/variables" | grep terminal)

# Get terminal ID of terminal 3
terminal3=$(echo $terminals | awk '{print $3}' | cut -d '=' -f 2)

# Change directory to the game server root
qdbus org.kde.yakuake /yakuake/sessions runCommandInTerminal $terminal3 "cd $HOME/workspace/MTGServer/MMOCoreORB/bin/"

# Run the game server in terminal 3
qdbus org.kde.yakuake /yakuake/sessions runCommandInTerminal $terminal3 $HOME/workspace/MTGServer/MMOCoreORB/bin/core3
