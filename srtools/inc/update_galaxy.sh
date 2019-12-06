#!/bin/bash

IP=$(ip a | grep inet | grep /24 | awk '{print $2}' | cut -d "/" -f 1)

sudo mysql -e "use swgemu; update galaxy set address='$IP' where galaxy_id='2';"
