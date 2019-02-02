#!/bin/bash
# list all instances in Service of the ASG this instance is from
# IPs comma separated

# Pre Req Check
    # Check if required commands are installed
    for item in logger \
                jq \
                aws \
                curl
    do
        command -v $Item >/dev/null 2>&1 || \
            { cjg_showerror -s "requires {$item} but it's not installed. Aborting."; exit 1; }
    done

# Output the message to standard error as well as to the system log.
# Start with "Error DNS Check:"
function cjg_showerror {
    logger -s "Error DNS Check: $1" -p local0.warn;
}

function get_ips_this_asg {
    read instanceID region <<< $(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | \
        jq --compact-output --raw-output --exit-status '.instanceId, .region') || \
            { cjg_showerror "Can't recover Meta-Data Instance ID and Region. Aborting"; exit 1; }

    #echo "the instance ID is $instanceID, in region $region"

    asgName=$(aws autoscaling describe-auto-scaling-instances \
        --output json --region $region \
        --instance-ids $myInstanceID \
        --query "AutoScalingInstances[0]" | \
        jq -rce '.AutoScalingGroupName') || \
            { cjg_showerror "Can't recover ASG Name containing instance '$myInstanceID'. Aborting"; exit 1; }

    #echo "the asg Name is $asgName"

    readarray instanceids <<< $(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-name $asgName --output json --region $region \
        --query 'AutoScalingGroups[*].Instances[?LifecycleState==`InService`]' | \
        jq -rce '.[] | .[] | .InstanceId') || \
            { cjg_showerror "Can't recover any Instance ID in the ASG '$asgName'. Aborting"; exit 1; }

    #echo "the instance IDs are $instanceids"

    ipaddresses=$(aws ec2 describe-instances --output json --region $region \
        --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PrivateIpAddress:PrivateIpAddress}" --instance-id $instanceids | \
        jq -rce '.[] | .[] | .PrivateIpAddress') || \
            { cjg_showerror "Can't recover any Instance IP in the ASG '$asgName' for instances '$instanceids'. Aborting"; exit 1; }
    
    echo $ipaddresses
}

ips=$(get_ips_this_asg) || \
            { cjg_showerror "Premature End of Script"; exit 1; }
    

echo "the IPs are:"

# List of IP
# echo $ipaddresses

# List of IP, comma separated
output=""
for ipaddress in $ips
do
    if [ -z "$output" ]
    then
        output="${ipaddress}"
    else
        output="${output},${ipaddress}"
    fi
done
echo $output
