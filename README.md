# aws-zero-downtime-deployment-practice
The program is a practice birthday reminder wrote in golang. It will be require to golang install before deployment.

The deployment script can use on any Linux system. The region for 

### Serverless Structure:
Structure: active-active, multi-region backend.

In `aws/event/apigateway/` contains the code for lambda function.

The script will deploy to two region for high availability.  

##### First of all, you need to have a hosted zone in Route53. This domain will be use for your multi-region app endpoint.

We assume you have already setup the aws-cli on your machine.

#### 1. Create .env

Expiation:
```
AWS_ACCOUNT_ID= Your-AWS-account-ID
AWS_BUCKET_NAME= your-lambda-s3bucket
AWS_LAMBDA_STACK_NAME= stack-name-for-lambda-function
AWS_DATABASE_STACK_NAME= stack-name-for-database
AWS_DATATABLE_NAME= global-table-name-for-cross-region-access
AWS_REGION= a-list-of-region-you-want-to-deploy (seperate with space)
AWS_CROSSREGION_DOMAIN= domain-name-used-for-multi-region-access
AWS_HOSTED_ZONE_ID= hosted-zone-id-of-your-cross-region-domain-on-route53
AWS_BASEPATH_MAPPING= basepath-of-your-custom-domain
```

Example:
```
AWS_ACCOUNT_ID=<your account id>
AWS_BUCKET_NAME=birthday-reminder-cloudformation-package
AWS_CERTIFICATE_STACK_NAME=birthday-reminder-certificate-parameter
AWS_LAMBDA_STACK_NAME=birthday-reminder
AWS_DATABASE_STACK_NAME=birthday-reminder-db
AWS_DATATABLE_NAME=birthday
AWS_REGION=eu-central-1 eu-west-1
AWS_CROSSREGION_DOMAIN=example.com
AWS_HOSTED_ZONE_ID=<ZONE ID>
AWS_BASEPATH_MAPPING=v1
```

What is the final product look like?
```bash
# should return your expected http respond
$ curl https://AWS_CROSSREGION_DOMAIN/AWS_BASEPATH_MAPPING/resource
```

#### 2. issue certificate
```bash
# issue the certificate
$ make certificate
```
This step may be tricky. You need to go to cloudformation and check the event of the stack. Put the CNAME record into your hosted zone.

Please refer the following link to do so.
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-certificatemanager-certificate.html#cfn-certificatemanager-certificate-validationmethod

#### 3. deploy
```bash
# Install go module to compile the severless program
$ make install-mod

# setup the S3 bucket
$ make configure

# setup aws dynamodb
$ make dynamodb

# Upload the package to S3 bucket
$ make package

# Deploy CloudFormation Stack
$ make deploy

# Get url of the endpoint
$ make url
```
If this is your first deploy, you can simply type in the following.
```bash
$ make full-deploy
```

If DynamoDB is using pay_by_request mode, the auto scaling role can also removed from the template.

#### 4. testing
Check if this is working. 
```bash
#health check
$ curl https://your-domain-for-cross-region/v1/healthcheck
ok

#input
$ curl -X PUT -d '{"dateOfBirth":"2010-01-01"}' https://your-domain-for-cross-region/v1/hello/Jake

#query
$ curl https://your-domain-for-cross-region/v1/hello/Jake
{"message":"Hello, Jake. Your Birthday is in 20 days."}
```
