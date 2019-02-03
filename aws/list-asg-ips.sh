#!/bin/bash
# list all instances in Service of the ASG this instance is from
# IPs comma separated
# use 'jq -rce' for 'jq --raw-output --compact-output --exit-status'

# Output the message to standard error as well as to the system log.
function cjg_logerror() {
    logger -s "[DNS Check][Error] $1" -p user.err
}
function cjg_logdebug() {
    logger -s "[DNS Check][Debug] $1" -p user.debug
}

echo ""
echo "******************************************"
echo "************ START DNS Check *************"
echo "******************************************"
echo ""

# Pre Req Check
    # Check if required commands are installed
for item in logger \
                jq \
                aws \
                curl
    do
        command -v "$item" > /dev/null || \
            { cjg_logerror "requires {$item} but it's not installed. Aborting."; exit 1; }
    done


function get_ips_this_asg() {

    # Instance ID + Region
    curlcommand="curl -s http://169.254.169.254/latest/dynamic/instance-identity/document"
    output=$($curlcommand)
    if [ "$?" -ne 0 ] || [ -z "$output" ] ; then
        cjg_logerror "Can't recover Meta-Data. Aborting"; exit 1;
    fi

    region=$(jq -rce '.region' 2> /dev/null <<< $output)
    if [ "$?" -ne 0 ] || [ -z "$region" ] ; then
        cjg_logerror "Can't extract Region from Meta-Data. Aborting"; exit 1;
    fi

    instanceID=$(jq -rce '.instanceId' 2> /dev/null <<< $output)
    if [ "$?" -ne 0 ] || [ -z "$instanceID" ] ; then
        cjg_logerror "Can't extract Instance ID afrom Meta-Data. Aborting"; exit 1;
    fi

    cjg_logdebug "Meta Data Extraction finished, the instance ID is $instanceID, in region $region"

    # ASG Name
    awscommand="aws autoscaling describe-auto-scaling-instances --output json --region $region --instance-ids $instanceID"
    output=$($awscommand)

    if [ "$?" -ne 0 ] || [ -z "$output" ] ; then
        cjg_logerror "Can't recover ASG Name containing instance '$instanceID'. Aborting"
        cjg_logdebug "AWS CLI: $awscommand"
        cjg_logdebug "AWS Result: $output"
        exit 1
    fi

    asgName=$(jq -rce '.AutoScalingInstances[0] | .AutoScalingGroupName' 2> /dev/null <<< $output)
    if [ "$?" -ne 0 ] || [ -z "$asgName" ] ; then
        cjg_logerror "Can't extract ASG Name containing instance '$instanceID'. Aborting";
        cjg_logdebug "the asg Name is $asgName"
        cjg_logdebug "AWS CLI: $awscommand"
        cjg_logdebug "AWS Result: $output"
        exit 1;
    fi

    cjg_logdebug "ASG Identification finished, the ASG Name is $asgName"

    #cjg_logdebug "the asg Name is $asgName"

    # readarray instanceids <<< $(aws autoscaling describe-auto-scaling-groups \
    #     --auto-scaling-group-name $asgName --output json --region $region \
    #     --query 'AutoScalingGroups[*].Instances[?LifecycleState==`InService`]' | \
    #     jq -rce '.[] | .[] | .InstanceId' || \
    #         { cjg_logerror "Can't recover any Instance ID in the ASG '$asgName'. Aborting"; exit 1; })

    # Instances inServcie in ASG
    output=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-name $asgName --output json --region $region \
        --query 'AutoScalingGroups[*].Instances[?LifecycleState==`InService`]')

    if [ "$?" -ne 0 ] || [ -z "$output" ] ; then
        cjg_logerror "Can't recover any Instance ID in Service in the ASG '$asgName'. Aborting"
        exit 1
    fi

    instanceids=$(jq -rce '.[] | .[] | .InstanceId' 2> /dev/null <<< $output)
    if [ "$?" -ne 0 ] || [ -z "$instanceids" ] ; then
        cjg_logerror "Can't extract any Instance ID in Service in the ASG '$asgName'. Aborting";
        cjg_logdebug "the instance ids are $instanceids"
        cjg_logdebug "AWS CLI: $awscommand"
        cjg_logdebug "AWS Result: $output"
        exit 1;
    fi

    #cjg_logdebug "the instance IDs are $instanceids"

    ipaddresses=$(aws ec2 describe-instances --output json --region $region \
        --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PrivateIpAddress:PrivateIpAddress}" --instance-id $instanceids | \
        jq -rce '.[] | .[] | .PrivateIpAddress' || \
            { cjg_logerror "Can't recover any Instance IP in the ASG '$asgName' for instances '$instanceids'. Aborting"; exit 1; })
    
    echo $ipaddresses
}

ips=$(get_ips_this_asg)

if [ "$?" -ne 0 ] ; then
    cjg_logerror "Premature End of Script"; exit 1;
fi
    

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

