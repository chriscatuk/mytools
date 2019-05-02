#!/bin/bash

# Script for Octopus
# Convert 2 vhd files located in S3 into an AMI

# tests locally
env_aws="lab"
NAME="cisco"
vhd_path1="forwarder-va.vhd"
vhd_path2="dynamic.vhd"
bucket_name=""

# SET AWS environement
export AWS_DEFAULT_REGION="eu-west-1"
export AWS_DEFAULT_PROFILE=$env_aws

# Define a usique name for AMIs (fix crash on name already taken)
# isodate=$(date '+%Y%m%d%H%M%S')
# uniquename="${NAME}_${isodate}"

echo "Bucket is $bucket_name"

# Run Instance from shared Tamale AMI
echo "Creating image from $vhd_path1 and $vhd_path2"
json_containers="[\
    {\
        \"Description\": \"First disk\",\
        \"Format\": \"vhd\",\
        \"UserBucket\": {\
            \"S3Bucket\": \"${bucket_name}\",\
            \"S3Key\": \"${vhd_path1}\"\
        }\
    },\
    {\
        \"Description\": \"Second disk\",\
        \"Format\": \"vhd\",\
        \"UserBucket\": {\
            \"S3Bucket\": \"${bucket_name}\",\
            \"S3Key\": \"${vhd_path2}\"\
        }\
    }\
]"

output=$(aws ec2 import-image --encrypted --description "Cisco" --disk-containers "$json_containers")

if [ "$?" -ne 0 ] || [ -z "$output" ] ; then
    echo "Failed" >&2
    echo "$output" >&2
    exit 1
fi

echo "*************************"
echo "*         OUTPUT        *"
echo $output
echo "*                       *"
echo "*************************"

taskid=$(jq -rce '.ImportTaskId' <<< $output)
if [ "$?" -ne 0 ] || [ -z "$taskid" ] ; then
    echo "Can't extract TaskID. Aborting" >&2
    echo "Output: $taskid" >&2
    exit 1;
fi

echo "******************************************"
echo "*                 TASKID                 *"
echo "* taskid: $taskid"
echo "* to follow its progress:"
echo "* aws ec2 describe-import-image-tasks --import-task-ids $taskid --profile $AWS_DEFAULT_PROFILE --region $AWS_DEFAULT_REGION"
echo "******************************************"

echo "*************************"
echo "*     Progression       *"
echo "*************************"

# init task_progress with something. Will stop the loop when it gets empty
task_progress_output="0"

while [ ! -z "$task_progress_output" ]
do

    sleep 20
    output=$(aws ec2 describe-import-image-tasks --import-task-ids $taskid)

    # ImportImageTasks[0].Status
    # active — The import task is in progress.
    # deleting — The import task is being canceled.
    # deleted — The import task is canceled.
    # updating — Import status is updating.
    # validating — The imported image is being validated.
    # validated — The imported image was validated.
    # converting — The imported image is being converted into an AMI.
    # completed — The import task is completed and the AMI is ready to use.
    task_status=$(jq -rce '.ImportImageTasks[0] | .Status' <<< $output)
    if [ "$?" -ne 0 ] || [ -z "$task_status" ] ; then
        echo "Can't extract Task Status. Aborting" >&2
        echo "Output: $output" >&2
        exit 1;
    fi

    # Human readable Output: ImportImageTasks[0].StatusMessage
    task_message=$(jq -rce '.ImportImageTasks[0] | .StatusMessage' <<< $output)
    if [ "$?" -ne 0 ] || [ -z "$task_message" ] ; then
        task_message="";
    fi

    # Progression if exist: ImportImageTasks[0].Progress
    task_progress=$(jq -rce '.ImportImageTasks[0] | .Progress' <<< $output)
    if [ "$?" -ne 0 ] || [ -z "$task_progress" ] ; then
        task_progress_output="";
    else
        task_progress_output="$task_progress %: ";
    fi

    echo "* ${task_progress_output}${task_message}"
done

if [ ! "$task_progress" = "completed" ] ; then
    echo "Task Status is not 'Completed'. Returning an error" >&2
    echo "* to follow its progress:" >&2
    echo "* aws ec2 describe-import-image-tasks --import-task-ids $taskid --profile $AWS_DEFAULT_PROFILE --region $AWS_DEFAULT_REGION" >&2
    exit 1
fi


echo "*************************"
echo "*     AMI Created       *"
echo "*************************"

echo $output

# Get AMI ID
ami_id=$(jq -rce '.ImportImageTasks[0] | .ImageId' <<< $output)
if [ "$?" -ne 0 ] || [ -z "$task_mesami_idsage" ] ; then
    echo "AMI ID can't be found. Aborting" >&2
    echo "* aws ec2 describe-import-image-tasks --import-task-ids $taskid --profile $AWS_DEFAULT_PROFILE --region $AWS_DEFAULT_REGION" >&2
    exit 1
fi

# Tag AMI
echo "Now applying tag to the image $ami_id..."
echo "* Name: $NAME"
echo "* env: $env_aws"
echo "* immutable: False"

# echo "Adding tags to Encrypted AMI $AMI_ENC..."
aws ec2 create-tags --resources $ami_id \
    --tags Key=Name,Value=$NAME \
    Key=env,Value=$env_aws \
    Key=immutable,Value=False

echo "Image $ami_id is ready (Please, check if it is encrypted)"
