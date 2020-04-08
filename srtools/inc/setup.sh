#!/bin/bash

# Check for SR ghetto Git structure
is_sr() {
  if [ -f "$HOME/workspace/Core3/Makefile" ]; then
    logger SRTools: "SR file structure detected! Fixing structure..."
    return 0
  else
    return 1
  fi
}

pub10_support_compile() {
  if [ -d "$HOME/workspace/Core3" ]; then
    logger SRTools: "$HOME/workspace/Core3 already exists! Please backup your files and remove it first!"
    exit 0
  fi

  logger SRTools: "Cloning Core3..."
  git clone -b $core3_repo_branch $core3_repo_url $HOME/workspace/Core3
  cd $HOME/workspace/Core3/MMOCoreORB/
  logger SRTools: "Building Core3..."
  make -j $(nproc)

  logger SRTools: "Updating tre path in config..."
  sed -i 's/TrePath = "\/home\/swgemu\/Desktop\/SWGEmu"/TrePath = "\/home\/swg\/workspace\/tre"/g' $HOME/workspace/Core3/MMOCoreORB/bin/conf/config.lua
  logger SRTools: "Copying config to config-local..."
  cp $HOME/workspace/Core3/MMOCoreORB/bin/conf/config.lua $HOME/workspace/Core3/MMOCoreORB/bin/conf/config-local.lua
}

non_pub10_support_compile() {
  if [ -d "$HOME/workspace/Core3" ]; then
    logger SRTools: "$HOME/workspace/Core3 already exists! Please backup your files and remove it first!"
    exit 0
  fi

  if [ -d "$HOME/workspace/PublicEngine" ]; then
    logger SRTools: "$HOME/workspace/PublicEngine alerady exists! Please backup your files and remove it first!"
    exit 0
  fi

  logger SRTools: "Cloning Core3..."
  git clone -b $core3_repo_branch $core3_repo_url $HOME/workspace/Core3
  logger SRTools: "Cloning PublicEngine..."
  git clone -b $engine_repo_branch $engine_repo_url $HOME/workspace/PublicEngine

  if is_sr; then
    mkdir $HOME/workspace/MMOCoreORB
    mv $HOME/workspace/Core3/* $HOME/workspace/MMOCoreORB
    mv $HOME/workspace/Core3/.* $HOME/workspace/MMOCoreORB
    mv $HOME/workspace/MMOCoreORB $HOME/workspace/Core3
  fi

  logger SRTools: "Building Engine..."
  cd $HOME/workspace/PublicEngine/MMOEngine && make
  logger SRTools: "Linking Engine..."
  ln -s $HOME/workspace/PublicEngine/MMOEngine $HOME/workspace/Core3/MMOEngine
  logger SRTools: "Building Core3..."
  cd $HOME/workspace/Core3/MMOCoreORB && make build-cmake -j $(nproc)

  logger SRTools: "Updating tre path in config..."
  sed -i 's/TrePath = "\/home\/swgemu\/Desktop\/SWGEmu"/TrePath = "\/home\/swg\/workspace\/tre"/g' $HOME/workspace/Core3/MMOCoreORB/bin/conf/config.lua
}

import_sql() {
  logger SRTools: "Dropping swgemu database if it exists..."
  sudo mysql -e "DROP DATABASE IF EXISTS swgemu"
  logger SRTools: "Creating swgemu database..."
  sudo mysql -e "CREATE DATABASE swgemu"
  if [ ! -f $HOME/workspace/Core3/MMOCoreORB/sql/swgemu.sql ]; then
    logger SRTools: "swgemu.sql does not exist!"
    exit 1
  fi
  if [ ! -f $HOME/workspace/Core3/MMOCoreORB/sql/mantis.sql ]; then
    logger SRTools: "mantis.sql does not exist!"
    exit 1
  fi
  logger SRTools: "Importing data into swgemu database..."
  sudo mysql swgemu < $HOME/workspace/Core3/MMOCoreORB/sql/swgemu.sql
  sudo mysql swgemu < $HOME/workspace/Core3/MMOCoreORB/sql/mantis.sql
  logger SRTools: "Updating Galaxy IP address..."
  $HOME/.scripts/srtools/inc/update_galaxy.sh
}

if [[ $pub10_compile == "y" ]]; then
  pub10_support_compile
  if [[ $1 == "migrate_fresh" ]]; then
    import_sql
  fi
else
  non_pub10_support_compile
  if [[ $1 == "migrate_fresh" ]]; then
    import_sql
  fi
fi
