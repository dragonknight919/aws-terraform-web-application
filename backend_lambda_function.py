import boto3
import json


def lambda_handler(event, context):
    dynamodb = boto3.client("dynamodb")
    table_scan = dynamodb.scan(TableName="minimal-backend-table")

    items = [
        {"id": item["id"]["N"], "name": item["name"]["S"]}
        for item in table_scan["Items"]
    ]

    response = {
        "statusCode": 200,
        "headers": {
            'Access-Control-Allow-Origin': '*',
        },
        "body": json.dumps(items)
    }

    return response
