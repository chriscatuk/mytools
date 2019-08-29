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
    
def lambda_handler(event, context):
    
    regions = get_regions()
            