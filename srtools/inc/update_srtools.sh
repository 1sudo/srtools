#!/bin/bash

logger SRTools: "Updating SRTools..."
cd $HOME/.scripts/srtools
git pull
/home/swg/.scripts/srtools/srtools.sh
