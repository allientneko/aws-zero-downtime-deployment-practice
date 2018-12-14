# birthday-remainder
The program is wrote in golang. It will be require to golang install before deployment.

The deployment script can use on any Linux system. The region for 

###Serverless:
Structure: a active-active, multi-region backend.

The script will deploy to two region for high availability.  
Step 1~3 are the steps to setup a cross region service.

For step 4, it may require a a custom url for AWS API Gateway.
https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains.html


####1. Create .env

```
AWS_ACCOUNT_ID= <Your AWS account ID>
AWS_BUCKET_NAME= your-lambda-s3bucket
AWS_LAMBDA_STACK_NAME= stack-name-for-lambda-function
AWS_DATABASE_STACK_NAME= stack-name-for-database
AWS_DATATABLE_NAME= global-table-name-for-cross-region-access
AWS_REGION_1= primary-region-you-want-to-deploy
AWS_REGION_2= secondary-region-you-want-to-deploy
```

####2. install AWS CLI
```bash
# use brew to install
$ brew install awscli

```

####3. deploy
```bash
# Install go module to compile the program
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

use ``make url`` to get back the API Gateway Endpoint for more action. Including adding health check. 

The output is important for the next step if you need the app to be multi region.


####4. Setup cross-region service domain
If you do not have a domain name, just skip this step.

https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains.html

After applying the certificate and creating a region custom domain for the Gateway API, you will get back a edge domain.

Add the following to the .env

```
AWS_HOSTED_ZONE_ID=The-hosted-zone-in-which-we-will-create-records
AWS_CROSSREGION_DOMAIN=your-domain-for-cross-region
AWS_REGION1_HEALTHCHECK_ENDPOINT=the-endpoint-of-region-one-getting-from-make-url
AWS_REGION2_HEALTHCHECK_ENDPOINT=the-endpoint-of-region-one-getting-from-make-url
AWS_REGION1_ENDPOINT=region1-endpoint-of-edge-domain-from-adding-custom-domain
AWS_REGION1_ENDPOINT=region2-endpoint-of-edge-domain-from-adding-custom-domain
``` 

Then run the script.
```bash
# add multi-region domain to the API Gateway
$ make dns
```

check if this is working. 
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
