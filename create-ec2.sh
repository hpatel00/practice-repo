#!/bin/bash

if [ -z "$1" ]; then
  echo -e "\e[31mInput Machine Name is Needed\e[0m"
  exit 1
fi

COMPONENT=$1
ZONE_ID="Z0150156UD0J2BIEAJM9"

CREATE_EC2() {
  PRIVATE_IP=$(aws ec2 run-instances \
        --image-id ${AMI_ID} \
        --instance-type t2.micro \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" \
        --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}" \
        --security-group-ids ${SGID} \
        | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

  sed -e "s/COMPONENT/${COMPONENT}/" -e "s/IPADDRESS/${PRIVATE_IP}/" route53.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq
}

#AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" | jq '.Images[].ImageId' | sed -e 's/"//g')
AMI_ID="ami-0e19bad5b5aceaea2"
SGID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=allow-all-from-public" | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')

if [ "$1" == "all" ]; then
  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq redis ; do
    COMPONENT=$component
    CREATE_EC2
  done
else
    CREATE_EC2
fi