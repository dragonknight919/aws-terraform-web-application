import boto3
import json


def lambda_handler(event, context):
    dynamodb = boto3.client("dynamodb")
    table_scan = dynamodb.scan(TableName="minimal-backend-table")

    response = {
        "statusCode": 200,
        "body": json.dumps(table_scan["Items"])
    }

    return response
