import os
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

client = boto3.client('ec2')

def get_regions():
 
    regions = [region['RegionName']
                for region in client.describe_regions()['Regions']]
                
    logger.info("List of regions: {}".format(', '.join(regions)))
    return regions
    
def assume_role(account, region):
    
    sts_response = sts.assume_role(RoleArn="arn:aws:iam::" + account + ":" + os.environ['AssumedRoleName'],
                                            RoleSessionName="lambda-session-role")
                                            
    awsAccessKeyId = sts_response['Credentials']['AccessKeyId']
    awsSecretAccessKey = sts_response['Credentials']['SecretAccessKey']
    awsSessionToken = sts_response['Credentials']['SessionToken']
        
    assumed_role = boto3.client('ec2', aws_access_key_id=awsAccessKeyId, aws_secret_access_key=awsSecretAccessKey,
               aws_session_token=awsSessionToken, region_name=region)
               
    return assumed_role

def lambda_handler(event, context):
    
    regions = get_regions()
            