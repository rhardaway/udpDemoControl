#!/bin/bash

###############################################
# Copyright (c)  2015-now, TigerGraph Inc.
# All rights reserved
# TGSE Demo Control
# Author: robert.hardaway@tigergraph.com
################################################

echo "This script will output the current state for ec2 instances"
echo '   Null indicates NOT running'
echo ''
echo 'Current date & time'
echo ''
date
TZ=America/New_York date
TZ=America/Denver date
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

echo " index        hostName       instanceId     ipAddress       current state"

for i in "${!hostName[@]}"
do
  currentState=$(aws ec2 describe-instance-status --instance-ids ${instanceId[$i]} | jq '.InstanceStatuses[0].InstanceState.Name')
  instanceId=$(aws ec2 describe-instance-status --instance-ids ${instanceId[$i]} | jq '.InstanceStatuses[0].InstanceId')
  echo "  $i       ${hostName[$i]}    ${instanceId}  ${ipAddress[$i]}    $currentState"
done

echo ''
echo 'RDS instance state'

## RDS - same
rds_props_file='./dbList.txt'
if [ -f "$rds_props_file" ]
then
  while IFS=',' read -r key value; do
#     echo "key is $key"
     instanceName+=($key)
  done < "$rds_props_file"
else
  echo "missing an rds props file"
  exit 0
fi

echo " index        instanceName          current state      class"

for i in "${!instanceName[@]}"
do
  currentState=$(aws rds describe-db-instances --db-instance-identifier ${instanceName[$i]} | jq '.DBInstances[0].DBInstanceStatus')
  currentClass=$(aws rds describe-db-instances --db-instance-identifier ${instanceName[$i]} | jq '.DBInstances[0].DBInstanceClass')
  echo "  $i       ${instanceName[$i]}    $currentState    $currentClass"
done
