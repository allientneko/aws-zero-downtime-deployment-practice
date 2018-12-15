include .env

clean:
		@rm -rf deployments/serverless/dist
		@mkdir -p deployments/serverless/dist

build: clean
		GOOS=linux go build -o deployments/serverless/dist/handler/getHandler aws/event/apigateway/getHandler.go aws/event/apigateway/dynamodb.go
		GOOS=linux go build -o deployments/serverless/dist/handler/putHandler aws/event/apigateway/putHandler.go aws/event/apigateway/dynamodb.go
		GOOS=linux go build -o deployments/serverless/dist/handler/healthCheck aws/event/apigateway/healthCheck.go

run:
		aws-sam-local local start-api

install:
		go get github.com/aws/aws-lambda-go/events
		go get github.com/aws/aws-lambda-go/lambda
		go get github.com/stretchr/testify/assert

install-dev:
		go get github.com/awslabs/aws-sam-local

install-mod:
		go mod download

certificate:
		$(foreach region,$(AWS_REGION), \
		aws cloudformation deploy \
			--template-file deployments/serverless/acm-certificate.yaml \
			--region $(region) \
			--capabilities CAPABILITY_IAM \
			--stack-name $(AWS_CERTIFICATE_STACK_NAME) \
			--parameter-overrides Domain=$(AWS_CROSSREGION_DOMAIN) HostedZoneID=$(AWS_HOSTED_ZONE_ID);)

test:
		go test ./... --cover

configure:
		$(foreach region,$(AWS_REGION), \
		aws s3api create-bucket \
			--bucket $(region)-$(AWS_BUCKET_NAME) \
			--region $(region) \
			--create-bucket-configuration LocationConstraint=$(region); )

dynamodb:
		$(foreach region,$(AWS_REGION), \
			aws cloudformation deploy \
        			--template-file deployments/dynamodb.yaml \
        			--region $(region) \
        			--capabilities CAPABILITY_IAM \
        			--stack-name $(AWS_DATABASE_STACK_NAME) \
        			--parameter-overrides DataTable=$(AWS_DATATABLE_NAME); )
		aws dynamodb create-global-table \
			--global-table-name $(AWS_DATATABLE_NAME) \
			--replication-group $(foreach region,$(AWS_REGION), RegionName=$(region))

package: build
		$(foreach region,$(AWS_REGION), \
		aws cloudformation package \
			--template-file deployments/serverless/serverless-template.yaml \
			--s3-bucket $(region)-$(AWS_BUCKET_NAME) \
			--region $(region) \
			--output-template-file $(region)_serverless_package.yml; )

deploy:
		$(foreach region,$(AWS_REGION), \
		aws cloudformation deploy \
			--template-file $(region)_serverless_package.yml \
			--region $(region) \
			--capabilities CAPABILITY_IAM \
			--stack-name $(AWS_LAMBDA_STACK_NAME) \
			--parameter-overrides DataTable=$(AWS_DATATABLE_NAME) Basepath=$(AWS_BASEPATH_MAPPING); )

url:
		$(foreach region,$(AWS_REGION), \
		printf "region: %s\n" $(region); \
		aws cloudformation describe-stacks \
			--region $(region) \
			--stack-name $(AWS_LAMBDA_STACK_NAME) \
			| jq -r ".Stacks[0].Outputs[0].OutputValue" -j; echo "\n"; )
