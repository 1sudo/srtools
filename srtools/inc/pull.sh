#!/bin/bash

core3_pid=$(pidof core3)
core3_tty=$(ps -ef | grep $core3_pid | awk 'FNR == 1 {print $6}' | cut -d '/' -f 2)
temp_dir="$HOME/.temp/"


kill_core3() {
  if [[ $core3_pid != "" ]]; then
    logger SRTools: "Saving to database prior to shutting down..."
    sudo $HOME/.scripts/ttyecho -n /dev/pts/$core3_tty save
    logger SRTools: "Allowing 30 seconds for database save..."
    sleep 30
    logger SRTools: "Killing Core3..."
    sudo pkill -9 $core3_pid
  fi
}

if_exists_delete() {
  if [ $1 == "f" ]; then
    if [ -f $2 ]; then
      logger SRTools: "$2 found, deleting..."
      rm -f $2
    fi
  else
    if [ -d $2 ]; then
      logger SRTools: "$2 found, deleting..."
      rm -rf $2
    fi
  fi
}

backup_databases() {
  # Delete old data from temp directory
  if_exists_delete d $temp_dir/databases
  if_exists_delete d $temp_dir/navmeshes
  if_exists_delete f $temp_dir/config.lua
  if_exists_delete f $temp_dir/config-local.lua
  if_exists_delete f $temp_dir/resource_manager_spawns.lua

  # Backup databases and configs
  logger SRTools: "Backing up databases..."
  mv $HOME/workspace/Core3/MMOCoreORB/bin/databases $temp_dir/
  logger SRTools: "Backing up config..."
  mv $HOME/workspace/Core3/MMOCoreORB/bin/conf/config.lua $temp_dir/

  # If config-local.lua exists, back it up too
  if [ -f $HOME/workspace/Core3/MMOCoreORB/bin/conf/config-local.lua ]; then
    logger SRTools: "Config-local.lua found, backing it up..."
    mv $HOME/workspace/Core3/MMOCoreORB/bin/conf/config-local.lua $temp_dir/
  fi

  # Backup resource manager since it is dynamic data and will keep resource spawns consistent
  logger SRTools: "Backing up resource manager spawns..."
  mv $HOME/workspace/Core3/MMOCoreORB/bin/scripts/managers/resource_manager_spawns.lua $temp_dir/

  # Backup navmeshes to prevent unnecessary navmesh generation (Very CPU intensive)
  logger SRTools: "Backing up navmeshes..."
  mv $HOME/workspace/Core3/MMOCoreORB/bin/navmeshes $temp_dir/
}

restore_databases() {
  # Delete repo data to be replaced by backup data
  if_exists_delete d $HOME/workspace/Core3/MMOCoreORB/bin/databases
  if_exists_delete d $HOME/workspace/Core3/MMOCoreORB/bin/navmeshes
  if_exists_delete f $HOME/workspace/Core3/MMOCoreORB/bin/conf/config.lua
  if_exists_delete f $HOME/workspace/Core3/MMOCoreORB/bin/conf/config-local.lua
  if_exists_delete f $HOME/workspace/Core3/MMOCoreORB/bin/scripts/managers/resource_manager_spawns.lua

  if [ -f $temp_dir/config-local.lua ]; then
    logger SRTools: "Config-local.lua found, restoring..."
    mv $temp_dir/config-local.lua $HOME/workspace/Core3/MMOCoreORB/bin/conf/
  fi

  logger SRTools: "Restoring config..."
  mv $temp_dir/config.lua $HOME/workspace/Core3/MMOCoreORB/bin/conf/
  logger SRTools: "Restoring databases..."
  mv $temp_dir/databases $HOME/workspace/Core3/MMOCoreORB/bin/
  logger SRTools: "Restoring navmeshes..."
  mv $temp_dir/navmeshes $HOME/workspace/Core3/MMOCoreORB/bin/
  logger SRTools: "Restoring navmeshes..."
  mv $temp_dir/resource_manager_spawns.lua $HOME/workspace/Core3/MMOCoreORB/bin/scripts/managers/
}

remove_core3() {
  if_exists_delete d $HOME/workspace/Core3
  if_exists_delete d $HOME/workspace/PublicEngine
}

pull_core3() {
  logger SRTools: "Pulling latest changes..."
  cd $HOME/workspace/Core3/MMOCoreORB
  git pull
}

clone_core3() {
  # Call the setup script as it is a clone and build utility
  $HOME/.scripts/srtools/inc/setup.sh
}

# Backup databases and re-compile
if [[ $1 == "hard" ]]; then
  kill_core3
  backup_databases
  remove_core3
  clone_core3
  restore_databases
fi

if [[ $1 == "soft" ]]; then
  kill_core3
  pull_core3
fi
