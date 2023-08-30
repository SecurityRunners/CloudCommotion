import os

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': os.environ.get('SENSITIVE_CONTENT')
    }
