# This file is meant for copy/pasting into command line when testing a policy

export test_role_name=tgw-connections-role
export test_profile_name=profile-test
export test_region_name=eu-west-1
export test_role_arn=arn:aws:iam::xxxxxxxx:policy/tgw-connections-role

aws iam create-role \
      --path /service-role/ \
      --role-name ${test_role_name} \
      --assume-role-policy-document file://assume_policy.json \
      --profile ${test_profile_name} \
      --region ${test_region_name}
aws iam create-policy \
      --policy-name ${test_role_name} \
      --policy-document file://policy.json \
      --profile ${test_profile_name} \
      --region ${test_region_name}

aws iam attach-role-policy \
      --policy-arn ${test_role_arn} \
      --role-name ${test_role_name}  \
      --profile ${test_profile_name} \
      --region ${test_region_name}


aws iam detach-role-policy \
      --policy-arn ${test_role_arn} \
      --role-name ${test_role_name}  \
      --profile ${test_profile_name} \
      --region ${test_region_name}

aws iam delete-policy \
      --policy-arn ${test_role_arn} \
      --profile ${test_profile_name} \
      --region ${test_region_name}

aws iam delete-role \
      --role-name ${test_role_name}  \
      --profile ${test_profile_name} \
      --region ${test_region_name}

