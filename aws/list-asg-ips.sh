#!/bin/bash
# list all instances of the ASG this instance is from
# IPs comma separated

myid=`curl --silent http://169.254.169.254/latest/meta-data/instance-id 2>&1`

instanceids=`aws autoscaling describe-auto-scaling-instances \
--output text --region eu-west-1 \
--instance-ids $myid \
--query "AutoScalingInstances[*].AutoScalingGroupName" \
| xargs -I '{}' aws autoscaling describe-auto-scaling-instances --region eu-west-1 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='{}'].[InstanceId]"`

ipaddresses=`aws ec2 describe-instances --output text --region eu-west-1 \
--query "Reservations[*].Instances[*].[PrivateIpAddress]" --instance-id $instanceids`

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
