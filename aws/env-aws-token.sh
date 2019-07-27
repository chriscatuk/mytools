#!/bin/bash

# Ask your Google Authentificator Token
# Create a AWS token and create/replace AWS Temporary Credentials environment variables for 3600s (--duration-seconds)
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_SESSION_TOKEN

# Usage:
# source env-aws-token --duration-seconds 3600 --serial-number arn:aws:iam::65AAAAAAAAAA869:mfa/firstname.lastname --profile <profile_name>'

# AWS profiles must be in ~/.aws/ for --profile option
# use "aws configure --profile <profile_name>" for setting up profiles

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
echo -n "Enter token followed by [ENTER]: "
read -s token
 
output=`aws sts get-session-token --token-code $token --output json "$@"`
rc=$?

if [[ $rc -ne 0 ]] ; then
echo "Exiting with an error"
echo aws sts get-session-token --token-code $token --output json "$@"
return $rc
fi

TOKENS=`echo ${output} | jq -r '.Credentials | "\(.AccessKeyId) \(.SecretAccessKey) \(.SessionToken)"'`

read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< ${TOKENS}
 
# thoses vars will be only in sub-shell
# run `source aws-token --profile EU` for current shell
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN
 
echo "==========================="
echo "- AWS_ACCESS_KEY_ID     setup with temporary security credentials"
echo "- AWS_SECRET_ACCESS_KEY setup with temporary security credentials"
echo "- AWS_SESSION_TOKEN     created"
echo "==========================="
echo "Use the following commands to check it worked:"
echo "aws sts get-caller-identity"
echo "aws iam get-user"
echo "aws iam list-account-aliases"
echo "==========================="
