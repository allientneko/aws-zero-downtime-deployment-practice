# birthday-remainder
The program is wrote in golang. It will be require to golang install before deployment.

The deployment script can use on any Linux system.

###Serverless:
Structure 
The script will deploy to two region for high availability.  
####1. Create .env

```
AWS_ACCOUNT_ID= <Your AWS account ID>
AWS_BUCKET_NAME= your-lambda-s3bucket
AWS_LAMBDA_STACK_NAME= stack-name-for-lambda-function
AWS_DATABASE_STACK_NAME= stack-name-for-database
AWS_DATATABLE_NAME= global-table-name-for-cross-region-access
AWS_REGION_1= primary-region-you-want-to-deploy
AWS_REGION_2= secondary-region-you-want-to-deploy
AWS_HOSTED_ZONE_ID= Your-AWS-Hosted-Zone-for-API-Gateway
```

####2. install AWS CLI

####3. deploy
```$bash
# setup the S3 bucket
$ make configure

# setup aws dynamodb
$ make dynamodb

# Upload data to S3 bucket
$ make package

# Deploy CloudFormation Stack
$ make deploy

# Get url of the endpoint
$ make url
```

If DynamoDB is using pay_by_request mode, the auto scaling role can also removed from the template.

use ``make url`` to get back the API Gateway Endpoint for more action. Including adding healthcheck.