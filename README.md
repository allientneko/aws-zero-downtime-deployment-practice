# birthday-remainder
The program is wrote in golang. It will be require to golang install before deployment.

The deployment script can use on any Linux system. The region for 

###Serverless:
Structure: a active-active, multi-region backend.

The script will deploy to two region for high availability.  
First of all, you need to have a hosted zone in Route53.

We assume you have already setup the aws-cli on your machine.

####1. Create .env

```
AWS_ACCOUNT_ID= Your-AWS-account-ID
AWS_BUCKET_NAME= your-lambda-s3bucket
AWS_LAMBDA_STACK_NAME= stack-name-for-lambda-function
AWS_DATABASE_STACK_NAME= stack-name-for-database
AWS_DATATABLE_NAME= global-table-name-for-cross-region-access
AWS_REGION_1= primary-region-you-want-to-deploy
AWS_REGION_2= secondary-region-you-want-to-deploy
AWS_CROSSREGION_DOMAIN= domain-name-used-for-multi-region-access
AWS_HOSTED_ZONE_ID= hosted-zone-id-on-route53
```

####2. issue certificate
```bash
# issue the certificate
$ make certificate
```
This step may be tricky. You need to go to cloudformation and check the event of the stack. Put the CNAME record into your hosted zone.

Please refer the following link to do so.
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-certificatemanager-certificate.html#cfn-certificatemanager-certificate-validationmethod

####3. deploy
```bash
# Install go module to compile the severless program
$ make install-mod

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

Check if this is working. 
```bash
#health check
$ curl https://your-domain-for-cross-region/healthcheck
ok

#input
$ curl -X PUT -d '{"dateOfBirth":"2010-01-01"}' https://your-domain-for-cross-region/hello/Jake

#query
$ curl https://your-domain-for-cross-region/hello/Jake
{"message":"Hello, Jake. Your Birthday is in 20 days."}
```
