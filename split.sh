#!/bin/bash

function makeitso {
	qdbus org.kde.yakuake /yakuake/sessions $1
	sleep 0.5
}

# Quad session the terminal
makeitso "org.kde.yakuake.addSessionQuad"

# Get Terminal IDs
terminal1=$(makeitso "org.kde.yakuake.activeTerminalId")
terminal2=$((terminal1+1))
terminal3=$((terminal2+1))
terminal4=$((terminal3+1))

# Export terminal IDs for use in other scripts
echo "terminal1=$terminal1" > $HOME/.scripts/variables
echo "terminal2=$terminal2" >> $HOME/.scripts/variables
echo "terminal3=$terminal3" >> $HOME/.scripts/variables
echo "terminal4=$terminal4" >> $HOME/.scripts/variables

# Run things inside each terminal session
makeitso "runCommandInTerminal $terminal1 htop"
makeitso "runCommandInTerminal $terminal2 srtools"
makeitso "runCommandInTerminal $terminal4 exit"
