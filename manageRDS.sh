#!/bin/bash

###############################################
# Copyright (c)  2015-now, TigerGraph Inc.
# All rights reserved
# TGSE Demo Control
# Author: robert.hardaway@tigergraph.com
################################################

echo "This script will start/stop rds instances"
echo ''
## open the props file: managedInstances.txt

props_file='./dbList.txt'
if [ -f "$props_file" ]
then
  while IFS=',' read -r key value; do
     instanceName+=($key)
     echo "instanceName is ${instanceName[$i]}"
  done < "$props_file"
else
  echo "missing a props file"
  exit 0
fi

echo ''
echo " index        hostName            ipAddress       current state"

for i in "${!instanceName[@]}"
do
  currentState=$(aws rds describe-db-instances --db-instance-identifier ${instanceName[$i]} | jq '.DBInstances[0].DBInstanceStatus')
  currentClass=$(aws rds describe-db-instances --db-instance-identifier ${instanceName[$i]} | jq '.DBInstances[0].DBInstanceClass')
  echo "  $i       ${instanceName[$i]}     $currentState" ${currentClass}
done

read -p "Enter the Instance Number you want to control: " instanceNum

read -p "Which action would you like to take: (start/stop): " action

echo " Managing  ${instanceName[$instanceNum]}"

## different syntax to manage Aurora clusters
isAuroraCluster=$(aws rds describe-db-instances --db-instance-identifier ${instanceName[$instanceNum]} | jq '.DBInstances[0].Engine')
echo "Engine is ${isAuroraCluster}"
SUBSTR='aurora'
if [[ "$isAuroraCluster" == *"$SUBSTR"* ]]; then
    auroraClusterName=$(aws rds describe-db-instances --db-instance-identifier ${instanceName[$instanceNum]} | jq '.DBInstances[0].DBClusterIdentifier' | tr -d "'\"")
    echo "This is an Aurora cluster, cluster name ${auroraClusterName}"
    aws rds ${action}-db-cluster --db-cluster-identifier ${auroraClusterName}
else
    echo "manage regular db instance"
    aws rds ${action}-db-instance --db-instance-identifier ${instanceName[$instanceNum]}
fi






echo 'Action complete'
echo ''



