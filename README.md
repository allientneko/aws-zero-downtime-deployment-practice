# birthday-remainder
The program is wrote in golang. It will be require to golang install before deployment.

The deployment script can use on any Linux system.

###Serverless:
####1. Create .env

``
AWS_ACCOUNT_ID=1234567890
AWS_BUCKET_NAME=your-bucket-name-for-cloudformation-package-data
AWS_STACK_NAME=your-cloudformation-stack-name
AWS_REGION=eu-central-1
``

####2. install AWS CLI

####3. deploy
```$bash
# setup the S3 bucket
$ make configure

# Upload data to S3 bucket
$ make package

# Deploy CloudFormation Stack
$ make deploy
```

If DynamoDB is using pay_by_request mode, the auto scaling role can also removed from the template.
