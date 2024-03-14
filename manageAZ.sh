#!/bin/bash

###############################################
# Copyright (c)  2022-now, Semarchy Inc.
# All rights reserved
# UDP Demo Control
# Author: robert.hardaway@semarchy.com
################################################

echo 'Manage various Azure resources'
echo ''

if [ -z "$1" ]; then
  echo "Need to prodice an action. Should be start or stop"
  exit 1
fi

action=$1

if [[ "$1" == *"start"* ]]
then
    echo "ok, starting stuff up"
elif [[ "$1" == *"stop"* ]]
then
    echo "ok, shutting stuff down"
else
    echo "need to enter start or stop"
    exit 0
fi

echo "Action is ${action}"

exit 2

## start vm
az vm ${action} -g MyResourceGroup -n MyVm

az vm ${action} -g US_Presales -n US-PreSales-UDP-Bastion-Prod
az vm ${action} -g US_Presales -n US-PreSales-UDP-xDM-Dev
az vm ${action} -g US_Presales -n US-PreSales-UDP-xDI-Prod

## database

az postgres server ${action} --name us-presales-udp-postgres-prod --resource-group US_Presales