#!/bin/bash

IP=$(ip a | grep inet | grep /29 | awk '{print $2}' | cut -d "/" -f 1)

mysql -e "use swgemu; update galaxy set address='$IP' where galaxy_id='2';"
