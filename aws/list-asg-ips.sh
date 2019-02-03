#!/bin/bash
# list all instances in Service of the ASG this instance is from
# IPs comma separated
# use 'jq -rce' for 'jq --raw-output --compact-output --exit-status'

export version=2019-02-03.01
export verbose=0

# Output the message to standard error as well as to the system log.
function cjg_logerror() {
    logger -s "[DNS Check][Error] $1" -p user.err
}
function cjg_logdebug() {
    if [ "$verbose" -ne 0 ] ; then
        logger -s "[DNS Check][Debug] $1" -p user.debug
    fi
}

function showHelp() {
cat << EOF  

    Usage: ./$0 [--verbose] [--help] [-i <instance-id> -r <aws-region>]
    (version: $version)

    Pre-requisites: jq, curl, aws cli

    -h, --help                          Display help

    -v, --verbose                       Run script in verbose mode. Will print out each step of execution.

    -i <instance-id>,   --instanceid    if absent, the script recover the current instance id
                                        This option is mandatory with --region (-r)

    -r <aws-region>,    --region        If absent, the script recover the current instance region
                                        This option is mandatory with --instanceid (-i)

EOF
}

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


function get_instance_info() {

    cjg_logdebug "********************************************************"
    cjg_logdebug "** Meta Data Extraction starting "
    cjg_logdebug "********************************************************"

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

    cjg_logdebug "** Meta Data Extraction finished"
    cjg_logdebug "** Instance ID: $instanceID, Region: $region"
    cjg_logdebug "********************************************************"

    echo "$instanceID $region"
}

# $1: instance id
# $2: region
function get_ips_asg() {

    instanceID=$1
    region=$2

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

    cjg_logdebug "** ASG Identification finished"
    cjg_logdebug "** ASG Name: $asgName "
    cjg_logdebug "********************************************************"


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

    cjg_logdebug "** Extraction successful of Instances in Servce"
    cjg_logdebug "** Instance IDs: $instanceids"
    cjg_logdebug "********************************************************"


    # Instances IPs
    output=$(aws ec2 describe-instances --output json --region $region --instance-id $instanceids \
        --query 'Reservations[*].Instances[*].{InstanceId:InstanceId,PrivateIpAddress:PrivateIpAddress}')

    if [ "$?" -ne 0 ] || [ -z "$output" ] ; then
        cjg_logerror "Can't recover any Instance IP in the ASG '$asgName' for instances '$instanceids'. Aborting"
        cjg_logdebug "AWS Result: $output"
        exit 1
    fi

    ipaddresses=$(jq -rce '.[] | .[] | .PrivateIpAddress' 2> /dev/null <<< $output)
    if [ "$?" -ne 0 ] || [ -z "$ipaddresses" ] ; then
        cjg_logerror "Can't extract any Instance IP in the ASG '$asgName' for instances '$instanceids'. Aborting";
        cjg_logdebug "the ip addresses are $ipaddresses"
        cjg_logdebug "AWS CLI: $awscommand"
        cjg_logdebug "AWS Result: $output"
        exit 1;
    fi
    cjg_logdebug "** Instance IPs: $ipaddresses"
    cjg_logdebug "********************************************************"

    echo $ipaddresses
}


# Options of the script
export param_id=""
export param_region=""
options=$(getopt -l "help,verbose,instanceid:,region:" -o "hvi:r:" -a -- "$@")
eval set -- "$options"
while  true
do
    case $1 in
        -h|--help)
            showHelp $0
            exit 0
            ;;
        -v|--verbose)
            shift
            export verbose=1
            #set -xv  # Set xtrace and verbose mode.
            ;;
        -i|--instanceid)
            shift
            export param_id=$1
            shift
            ;;
        -r|--region)
            shift
            export param_region=$1
            shift
            ;;
        --)
            shift
            break;;
        ?)
            showHelp $0
            exit 1
            ;;
    esac
done
if [ ! -z "$param_id" ] && [ -z "$param_region" ]; then
    cjg_logerror "When you specify an Instance, you must specify a Region too"
    showHelp $0
    exit 2
fi
if [ ! -z "$param_region" ] && [ -z "$param_id" ]; then
    cjg_logerror "When you specify a region, you must specify an instance too"
    showHelp $0
    exit 2
fi

cjg_logdebug ""
cjg_logdebug "******************************************"
cjg_logdebug "************ START DNS Check *************"
cjg_logdebug "******************************************"
cjg_logdebug ""

cjg_logdebug "Verbose: $verbose"
cjg_logdebug "ID provided: $param_id"
cjg_logdebug "Region provided: $param_region"
cjg_logdebug ""

# If Instance and Region not given, recover it localy
if [ -z "$param_region" ] && [ -z "$param_id" ]; then
    cjg_logerror "Recovering instance info via Meta Data"
    read param_id param_region <<< $(get_instance_info) 
    cjg_logdebug "** Passed down to the program"
    cjg_logdebug "** Instance ID: $param_id, Region: $param_region"
    cjg_logdebug "********************************************************"
fi

# Recover ASG and IPs
ips=$(get_ips_asg $param_id $param_region)

if [ "$?" -ne 0 ] ; then
    cjg_logerror "Premature End of Script. Run it with --verbose option for more details."; exit 1;
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

