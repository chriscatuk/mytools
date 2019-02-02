#!/bin/bash
# list all instances in Service of the ASG this instance is from
# IPs comma separated

# Check if required commands are installed
for item in logger \
            jq \
            aws \
            curl
  do
    command -v $Item >/dev/null 2>&1 || \
        { logger -s "DNS Check requires {$item} but it's not installed. Aborting."; exit 1; }
  done

read instanceID region <<< $(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | \
    jq -c -r '.instanceId, .region')

echo "the instance ID is $instanceID, in region $region"

asgName=$(aws autoscaling describe-auto-scaling-instances \
    --output json --region $region \
    --instance-ids $myInstanceID \
    --query "AutoScalingInstances[0]" | \
    jq -c -r '.AutoScalingGroupName')

echo "the asg Name is $asgName"

readarray instanceids <<< $(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $asgName --output json --region $region \
    --query 'AutoScalingGroups[*].Instances[?LifecycleState==`InService`]' | \
    jq -r '.[] | .[] | .InstanceId')

echo "the instance IDs are $instanceids"

ipaddresses=$(aws ec2 describe-instances --output json --region $region \
    --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PrivateIpAddress:PrivateIpAddress}" --instance-id $instanceids | \
    jq -r '.[] | .[] | .PrivateIpAddress')

echo "the IPs are:"

# List of IP
# echo $ipaddresses

# List of IP, comma separated
output=""
for ipaddress in $ipaddresses
do
    if [ -z "$output" ]
    then
        output="${ipaddress}"
    else
        output="${output},${ipaddress}"
    fi
done
echo $output
