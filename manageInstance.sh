#!/bin/bash

###############################################
# Copyright (c)  2015-now, TigerGraph Inc.
# All rights reserved
# TGSE Demo Control
# Author: robert.hardaway@tigergraph.com
################################################

echo "This script will start/stop ec2 instances"
echo ''
## open the props file: managedInstances.txt

props_file='./instanceList.txt'
if [ -f "$props_file" ]
then
  while IFS=',' read -r key value value2; do
#     echo "key is $key"
     hostName+=($key)
     instanceId+=($value)
     ipAddress+=($value2)
  done < "$props_file"
else
  echo "missing a props file"
  exit 0
fi

INSTANCE_NUM=0

echo ''
echo " index        hostName            ipAddress       current state"

for i in "${!hostName[@]}"
do
  currentState=$(aws ec2 describe-instance-status --instance-ids ${instanceId[$i]} | jq '.InstanceStatuses[0].InstanceState.Name')
  echo "  $i       ${hostName[$i]}    ${ipAddress[$i]}    $currentState"
done

read -p "Enter the Instance Number you want to control: " instanceNum

read -p "Which action would you like to take: (start/stop): " action

aws ec2 ${action}-instances --instance-ids ${instanceId[$instanceNum]}

echo 'Action complete'
echo ''



